module Account
  class SubscribeNotificationsController < ApplicationController
    def index
      @notifications = current_user.subscribe_notifications.page params[:page_sel]
    end

    def send_now
      if session[:subscribe_ids].present?
        SubscribeNotifiesJob.perform_later(current_user, session[:subscribe_ids].join(','))
        render js: "alert('#{t('.notice')}')"
      else
        render js: "alert('#{t('.alert')}')"
      end
    end
  end
end
