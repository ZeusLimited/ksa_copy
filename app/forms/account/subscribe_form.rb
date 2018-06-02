module Account
  class SubscribeForm < ActiveType::Object
    include Constants

    attribute :theme

    nests_many :subscribe_actions, default: proc { initialize_actions }
    nests_many :subscribe_warnings, default: proc { initialize_warinigs }

    private

    def initialize_actions
      Dictionary.subscribe_actions.map do |action|
        SubscribeAction.new(action_id: action.id)
      end
    end

    def initialize_warinigs
      Dictionary.subscribe_warnings.map do |warning|
        SubscribeAction.new(action_id: warning.id)
      end
    end
  end
end
