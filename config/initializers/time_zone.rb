# frozen_string_literal: true

# Override default_time_zone from Settings
if ActiveRecord::Base.connection.table_exists? 'settings'
  Time.zone_default = ActiveSupport::TimeZone.new(
    Setting.get_all('default_time_zone')['default_time_zone'],
  )
end
