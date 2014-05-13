$redis_config = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env] 

if $redis_config 
  $redis = Redis.new(host: $redis_config['host'], port: $redis_config['port']) 
end 