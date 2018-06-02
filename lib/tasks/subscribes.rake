# frozen_string_literal: true

namespace :subscribes do
  desc "Определение наступления события"
  task :set_actual_actions, [:user_id] => :environment do |task, args|
    users = if args.user_id
      [User.find(args.user_id)]
    else
      User.with_settings_for('subscribe_send_time')
          .where(settings: { value: "--- '#{Time.current.strftime('%H:%M')}'\n" })
    end
    users.each do |user|
      SubscribeNotifiesJob.perform_later user
    end
  end
end
