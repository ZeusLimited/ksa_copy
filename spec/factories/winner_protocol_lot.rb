# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :winner_protocol_lot do
    # winner_protocol
    # lot
    trait(:winner) { solution_type_id WinnerProtocolSolutionTypes::WINNER }
    trait(:single_source) { solution_type_id WinnerProtocolSolutionTypes::SINGLE_SOURCE }
    trait(:fail) { solution_type_id WinnerProtocolSolutionTypes::FAIL }
    trait(:cancel) { solution_type_id WinnerProtocolSolutionTypes::CANCEL }
  end
end
