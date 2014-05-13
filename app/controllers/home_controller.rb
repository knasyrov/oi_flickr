class HomeController < ApplicationController

  PHOTO_SOURCE_URL='https://farm%s.staticflickr.com/%s/%s_%s%s.%s'.freeze

  def index
  end

  def search
=begin    
    if @keyword = params[:keyword]
      @list = Flickr.search @keyword
    end
    render json: @list
  rescue Exception => e
    render json: 'Internal Error', status: :unprocessable_entity
=end
    if keyword = params[:keyword]
      key_name = "oi_cache:#{Base64.strict_encode64(keyword)}"

      $hiredis = EM::Hiredis.connect
      $hiredis.exists(key_name).callback do |val|
        unless val.to_i == 0
          $hiredis.get(key_name).callback do |list|
            Rails.logger.info list.inspect
            @list = Marshal.load(list)
            render json: @list
            request.env['async.callback'].call(response)
          end
        else
=begin          
          conn = Faraday.new "https://api.flickr.com" do |con|
            con.adapter :em_http
          end
          resp = conn.get '/services/rest/', {
            text: keyword,
            api_key: 'e21b01b84ac3e3c2972a6725b8cece83',
            format: :json
          }
          resp.on_complete {
            Rails.logger.info resp.body
            list = JSON.parse(resp.body)
            render json: 
            request.env['async.callback'].call(response)
          }
=end
        http = EM::HttpRequest.new("https://api.flickr.com/services/rest/").get :query => {
            method: 'flickr.photos.search',
            text: keyword,
            api_key: 'e21b01b84ac3e3c2972a6725b8cece83',
            format: :json,
            nojsoncallback: 1
          }
          http.callback do |rsp|
            @photos = JSON.parse(http.response)['photos']
            render json: @photos['photo'].map{|item| {thumb: url_t(item), link: url_b(item), title: item['title']}}
            request.env['async.callback'].call(response)
          end

          http.errback do |err|
 Rails.logger.info err
          end

         # $hiredis.set(key_name, Marshal.dump(list.to_a)).callback {
         #   $hiredis.expire(key_name, 30)
         # }
        end
      end
    end

    # https://api.flickr.com/services/rest/?method=flickr.photos.search&text=sex&api_key=e21b01b84ac3e3c2972a6725b8cece83
=begin
    EM.add_timer(5) do 
      render json: '@list'
      request.env['async.callback'].call(response)
    end
=end    
    throw :async    
  end

  def url_t(r); PHOTO_SOURCE_URL % [r['farm'], r['server'], r['id'], r['secret'], "_t", "jpg"] end
    def url_b(r); PHOTO_SOURCE_URL % [r['farm'], r['server'], r['id'], r['secret'], "_b", "jpg"] end

  def images

  end
end
