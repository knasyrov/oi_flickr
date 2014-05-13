class Flickr 

  def self.search keyword
    list = []
    key_name = "oi_cache:#{Base64.strict_encode64(keyword)}"
    if $redis.exists(keyword)
      list =  Marshal.load($redis.get(key_name))
    else
      FlickRaw.api_key="e21b01b84ac3e3c2972a6725b8cece83"
      FlickRaw.shared_secret="19f3c2e5bf493e44"

      list = flickr.photos.search text: keyword
      list.to_a.map!{|item| {thumb: FlickRaw.url_t(item), link: FlickRaw.url_b(item), title: item.title}}
      $redis.set(key_name, Marshal.dump(list.to_a))
      $redis.expire(key_name, $redis_config['cache_time'])
    end
    list
  end

end