# frozen_string_literal: true

class AdminMailerPreview < ActionMailer::Preview
  def user_approval_ru
    I18n.locale = :ru
    AdminMailer.user_approval(user)
  end

  def new_user_waiting_for_approval_ru
    I18n.locale = :ru
    AdminMailer.new_user_waiting_for_approval(user)
  end

  private

  def user
    User.first
  end
end
