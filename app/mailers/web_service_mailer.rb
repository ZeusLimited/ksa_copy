class WebServiceMailer < ApplicationMailer
  def contract_notification(user, contract)
    @contract = contract
    to = Rails.env.production? ? user.email : Rails.configuration.x.admin_emails

    mail to: to, subject: t('.subject'), bcc: Rails.configuration.x.admin_emails
  end
end
