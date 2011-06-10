REDIS_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/redis.yml")[RAILS_ENV]
$redis = Redis.new(:host => REDIS_CONFIG['host'], :port => REDIS_CONFIG['port'])
