Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.dsn = 'https://d8eb72fe5b6f46fc861a857962618615:73f259e5487e46a3a76f2840676aecb5@sentry.io/95625'
  config.environments = ['staging', 'production']
  config.proxy = 'http://ksadz_user:Ksf5310@inetm9.corp.gidroogk.com:8080' if Rails.env == 'production'
end
