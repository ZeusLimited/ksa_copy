class SubscribeNotifiesJob < ApplicationJob
  include Constants
  queue_as :default

  def perform(user, sub_ids = nil)
    User.transaction do
      # Определяем изменения
      ActualSubscribe.create_unless_exists
      subscribes = sub_ids.present? ? Subscribe.where(id: sub_ids.split(',')) : user.subscribes
      subscribes.find_each(batch_size: 50) do |subscribe|
        subscribe.subscribe_actions.each(&:occur_and_save)
        subscribe.update_structures
      end
      # Формируем и сохраняем сообщения
      actions = ActualSubscribe.select('action_id, days_before').order('days_before nulls last, action_id').distinct
      if actions.present?
        html = UserMailer.subscribe_html(actions)
        email = UserMailer.subscribe(user, actions)
        SubscribeNotification.create(user_id: user.id, format_html: html.body, format_email: email.body)
        # Отправляем сообщение
        email.deliver_now
      end
      # Удаляем подписку на удаленные лоты
      subscribes.each do |subscribe|
        subscribe.destroy unless subscribe.plan_lot_exists?
      end
    end
  end
end
