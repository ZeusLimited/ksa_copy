# frozen_string_literal: true

class Setting < RailsSettings::Base
  source Rails.root.join('config', 'app.yml')
  namespace Rails.env

  cache_prefix { '_torg' }
end
