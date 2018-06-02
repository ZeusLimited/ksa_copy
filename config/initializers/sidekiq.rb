Sidekiq::Extensions.enable_delay!

REDIS = YAML.load_file(File.join('config', 'redis.yml'))[Rails.env]

Sidekiq.configure_server do |config|
  config.redis = REDIS
end

Sidekiq.configure_client do |config|
  config.redis = REDIS
end
