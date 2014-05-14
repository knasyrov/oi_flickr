require 'eventmachine'
require 'em-hiredis'
require 'base64'

class Flickr 
  include EM::Deferrable

  PHOTO_SOURCE_URL  = 'https://farm%s.staticflickr.com/%s/%s_%s%s.%s'.freeze
  FLICKR_API_URL    = 'https://api.flickr.com/services/rest/'.freeze
  FLICKR_METHOD_NAME= 'flickr.photos.search'.freeze

  def initialize api_key, redis_cache_timeout = 300
    @api_key, @redis_cache_timeout = api_key, redis_cache_timeout
    EM.next_tick {
      @hiredis = EM::Hiredis.connect
    }
  end

  def search keyword
    key_name = "oi_cache:#{Base64.strict_encode64(keyword)}"
    Rails.logger.info keyword

    @hiredis.exists(key_name).callback do |val|
      unless val.to_i == 0
        @hiredis.get(key_name).callback do |list|
          @list = Marshal.load(list)
          succeed(@list)
        end.errback do |error|
          fail(error)
        end
      else
        http = EM::HttpRequest.new(FLICKR_API_URL).get :query => {
          method: FLICKR_METHOD_NAME,
          text: keyword,
          api_key: @api_key,
          format: :json,
          nojsoncallback: 1
        }
        http.callback do |rsp|
          json = JSON.parse(http.response)
          if json.key?('stat') && json['stat'] == 'fail'
            fail("FLICKR ERROR: #{json['message']}")
          else
            photos = json['photos']
            @list = photos['photo'].map{|item| {thumb: url_t(item), link: url_b(item), title: item['title']}}

            @hiredis.set(key_name, Marshal.dump(@list)).callback {
              @hiredis.expire(key_name, @redis_cache_timeout).callback {
                succeed(@list)
              }
            }
          end
        end
        http.errback do |err|
          fail(err)
        end  
      end  
    end
    self
  end


protected

  def url_t(r)
    PHOTO_SOURCE_URL % [r['farm'], r['server'], r['id'], r['secret'], "_t", "jpg"] 
  end

  def url_b(r)
    PHOTO_SOURCE_URL % [r['farm'], r['server'], r['id'], r['secret'], "_b", "jpg"]
  end

end