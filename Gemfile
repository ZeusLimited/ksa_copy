source 'https://rubygems.org'

# Core
gem 'rails'
gem "reform", ">= 2.2.0"
gem "reform-rails"
gem "trailblazer"
gem 'trailblazer-rails'

# Data
gem 'active_type'
gem 'activerecord-session_store'
gem 'ancestry'
gem 'arel'
gem 'cancancan'
gem 'dbf'
gem 'deep_cloneable'
gem 'devise'
gem 'draper'
gem 'migration_comments'
gem 'paper_trail'
gem 'pg'
gem 'rails-settings-cached'
gem 'uuidtools'
gem 'validates_russian', git: 'git@github.com:AgeevAndrew/validates_russian.git', branch: 'fix_bug_validate_kpp'

# Mails
gem 'foundation_emails'
gem 'inky-rb', require: 'inky'
gem 'premailer-rails'

# External services
gem 'fog-openstack'
gem 'net-ldap'
gem 'newrelic_rpm'
gem 'redis-namespace'
gem 'rest-client'
gem 'savon'
gem "sentry-raven"
gem 'sidekiq'
gem 'wash_out'
gem 'faker'
gem 'faker-russian'

# Views
gem 'axlsx', '~> 2.1.0.pre'
gem 'axlsx_rails'
gem 'chartkick'
gem 'gon'
gem 'kaminari'
gem 'nokogiri'
gem 'openxml_docx_templater'
gem 'rabl'
gem 'record_tag_helper'
gem 'redcarpet'
gem 'roo'
gem 'russian'
gem 'simple_form'
gem 'slim-rails'
gem 'turboboost'
gem 'turbolinks', '~> 5.0.0'
gem 'wannabe_bool'

# React
gem 'react_on_rails', '8.0.6'
gem 'mini_racer', platforms: :ruby
gem 'webpacker_lite'

# JS
gem 'cocoon'
gem 'coffee-rails'
gem 'jquery-fileupload-rails'
gem 'jquery-minicolors-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
# TODO, Следить за решением косяка https://github.com/fatdude/jquery-ui-themes-rails/issues/14
#      Затем upgrade до 0.0.12
gem 'jquery-ui-themes', '0.0.11'
gem 'maskmoney-rails'
# TODO, Upgrade after move to bootsrap 3 or 4
gem 'select2-rails', '~> 3.0'

# Themes
gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'bootstrap-timepicker-rails'
gem 'bootswatch-rails', '~> 0.5.0'
gem 'dynatree-rails'
gem 'sass-rails', '>= 3.2'
gem 'uglifier'

# Documantation
gem "apitome", git: 'git@github.com:jejacks0n/apitome.git', branch: 'master'
gem 'rspec_api_documentation'

# Ungrouping
gem 'browser'
gem 'business_time'
gem 'carrierwave'
gem 'coderay'
gem 'invisible_captcha'
gem 'markitup-rails', git: 'git@github.com:complistic-gaff/markitup-rails.git'
gem 'ru_propisju'
gem 'sys-filesystem'
gem 'whenever', :require => false

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-yarn', require: false
  gem 'guard-rspec', require: false
  # gem 'i18n-debug'
  gem 'letter_opener'
  gem 'meta_request'
  gem 'puma'
  gem 'rails_best_practices', require: false
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console', '~> 2.0'
end

group :test, :development do
  gem 'awesome_print'
  gem 'factory_girl_rails'
  gem 'fuubar'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-mocks'
  gem 'rspec-rails', '~> 3.0'
end

group :test do
  gem 'capybara'
  gem 'codecov', require: false
  # TODO, 1.11.5 не запускается, какаято херня. Разобраться при случае.
  gem 'cucumber-rails', require: false
  gem 'cucumber_factory', '1.11.4'
  gem 'cucumber_priority'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov', require: false
  gem 'spreewald'
end

group :production, :staging do
  gem 'mailgun_rails'
  gem 'unicorn'
end
