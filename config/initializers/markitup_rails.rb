include ApplicationHelper
Markitup::Rails.configure do |config|
  config.formatter = -> markup { markdown(markup) }
end
