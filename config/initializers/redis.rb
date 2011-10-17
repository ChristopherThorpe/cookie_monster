REDIS_CONFIG = YAML.load(ERB.new(File.read("#{RAILS_ROOT}/config/redis.yml")).result)[RAILS_ENV]
$redis = Redis.new(REDIS_CONFIG)
