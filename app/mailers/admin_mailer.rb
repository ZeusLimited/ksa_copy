class AdminMailer < ApplicationMailer
  def new_user_waiting_for_approval(user)
    @user = user
    mail(to: Setting.email_for_approve, cc: User.admins.pluck(:email), subject: 'Новый пользователь ждёт активации')
  end

  def user_approval(user)
    @user = user
    mail(to: user.email, subject: "Ваша учетная запись в #{Setting.app_name} активирована")
  end
end
