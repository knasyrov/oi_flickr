require 'flickr'

redis_config = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env] 

$flickr = Flickr.new 'e21b01b84ac3e3c2972a6725b8cece83', redis_config['cache_time']