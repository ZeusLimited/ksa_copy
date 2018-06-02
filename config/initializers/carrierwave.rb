require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

storage_conf = YAML.load_file(File.join('config', 'carrierwave_config.yml'))[Rails.env]
CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

CarrierWave.configure do |config|
  storage_conf.each do |key, value|
    config.send("#{key}=", value)
  end
end
