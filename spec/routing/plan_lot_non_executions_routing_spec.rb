require "spec_helper"

describe PlanLotNonExecutionsController, type: :routing do
  describe "routing" do
    let(:guid_hex) { UUIDTools::UUID.parse_raw(SecureRandom.random_bytes(16)).hexdigest  }

    it "routes to #index" do
      expect(get: "/plan_lot_non_executions/#{guid_hex}").to route_to("plan_lot_non_executions#index", guid: guid_hex)
    end

    it "routes to #create" do
      expect(post: "/plan_lot_non_executions/#{guid_hex}").to route_to("plan_lot_non_executions#create",
                                                                       guid: guid_hex)
    end
  end
end
