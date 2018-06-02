require "spec_helper"

describe Account::SubscribeNotificationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/account/subscribe_notifications").to route_to("account/subscribe_notifications#index")
    end

    it "routes to #send_now" do
      expect(post: "/account/subscribe_notifications/send_now").to route_to("account/subscribe_notifications#send_now")
    end
  end
end
