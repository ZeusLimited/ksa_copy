FactoryGirl.define do
  factory :subscribe_action do
    action_id 1
    days_before 1

    factory :subscribe_action_with_subscription do
      subscribe { build(:subscribe_with_plan_struct, plan_lot: create(:plan_lot)) }
    end

    trait(:confirm) { action_id SubscribeActions::CONFIRM }
    trait(:public) { action_id SubscribeActions::PUBLIC }
    trait(:open) { action_id SubscribeActions::OPEN }
    trait(:review) { action_id SubscribeActions::REVIEW }
    trait(:review_confirm) { action_id SubscribeActions::REVIEW_CONFIRM }
    trait(:reopen) { action_id SubscribeActions::REOPEN }
    trait(:winner) { action_id SubscribeActions::WINNER }
    trait(:winner_confirm) { action_id SubscribeActions::WINNER_CONFIRM }
    trait(:result) { action_id SubscribeActions::RESULT }
    trait(:contract) { action_id SubscribeActions::CONTRACT }
    trait(:fail) { action_id SubscribeActions::FAIL }
    trait(:cancel) { action_id SubscribeActions::CANCEL }
    trait(:delete) { action_id SubscribeActions::DELETE }
    trait(:public_warning) { action_id SubscribeWarnings::PUBLIC }
    trait(:open_warning) { action_id SubscribeWarnings::OPEN }
    trait(:summarize) { action_id SubscribeWarnings::SUMMARIZE }
  end
end
