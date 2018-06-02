class UserMailer < ApplicationMailer
  def subscribe(user, actions)
    @actions = actions
    @host = Rails.application.config.action_mailer[:default_url_options][:host]
    mail to: user.email, subject: t('.subscribe_subject')
  end

  def subscribe_html(actions)
    @actions = actions
    mail
  end
end
