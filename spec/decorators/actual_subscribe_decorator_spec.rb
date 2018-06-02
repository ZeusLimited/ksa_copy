require 'spec_helper'

describe ActualSubscribeDecorator do
  before(:each) { ActualSubscribe.create_unless_exists }

  let(:actual_subscribe) { build(:actual_subscribe).decorate }

  describe 'actual subscribe colors' do
    it "get background color warning for subscribes" do
      actual_subscribe.action_id = Constants::SubscribeWarnings::OPEN
      expect(actual_subscribe.background_class).to eq("warning")
    end
    it "get background color success for subscribes" do
      actual_subscribe.action_id = Constants::SubscribeActions::PUBLIC
      expect(actual_subscribe.background_class).to eq("success")
    end
    it "get background color alert for subscribes" do
      actual_subscribe.action_id = Constants::SubscribeActions::DELETE
      expect(actual_subscribe.background_class).to eq("alert")
    end
  end
end
