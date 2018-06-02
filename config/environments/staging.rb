require 'ipaddr'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  config.action_dispatch.ip_spoofing_check = false
  config.action_dispatch.trusted_proxies = [
    "127.0.0.1",      # localhost IPv4
    "::1",            # localhost IPv6
    "fc00::/7",       # private IPv6 range fc00::/7
    "10.0.0.0/8",     # private IPv4 range 10.x.x.x
    # "172.16.0.0/12",  # private IPv4 range 172.16.0.0 .. 172.31.255.255
    "192.168.0.0/16", # private IPv4 range 192.168.x.x
  ].map { |proxy| IPAddr.new(proxy) }

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  config.to_prepare { Devise::SessionsController.force_ssl }
  config.to_prepare { Devise::RegistrationsController.force_ssl }
  config.to_prepare { Devise::PasswordsController.force_ssl }

  # See everything in the log (default is :info)
  config.log_level = :info

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( dynatree* blog/*)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'raoesv-demo.t-org.net' }
  config.action_mailer.default_options = { from: 'no-reply@t-org.net' }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # config.middleware.use ExceptionNotifier,
  #   :email_prefix => "[Ksazd] ",
  #   :sender_address => 'noreply@rao-esv.ru',
  #   :exception_recipients => %w{archakov-as@rao-esv.ru ageev-aa@rao-esv.ru}

  # config.middleware.use ExceptionNotification::Rack,
  # :email => {
  #   :email_prefix => "[Ksazd] ",
  #   :sender_address => 'noreply@rao-esv.ru',
  #   :exception_recipients => %w{archakov-as@rao-esv.ru ageev-aa@rao-esv.ru},
  #   :ignore_exceptions => ['ActionView::TemplateError'] + ExceptionNotifier.ignored_exceptions
  # }

  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.mailgun_settings = {
    api_key: ENV['MAILGUN_API_KEY'],
    domain: 'mg.t-org.net',
  }
end
