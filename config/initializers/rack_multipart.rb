# frozen_string_literal: true

# Override default_time_zone from Settings
if ActiveRecord::Base.connection.table_exists? 'settings'
  Rack::Multipart::Parser.const_set('BUFSIZE', Setting.get_all('multipart_buffer_size')['multipart_buffer_size'])
end
