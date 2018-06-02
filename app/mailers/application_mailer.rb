# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  layout 'mailer'

  def url_options
    { host: default_url_options[:host] }
  end
end
