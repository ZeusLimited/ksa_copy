require "spec_helper"

describe ImportPlanLotsController, type: :routing do
  describe "routing" do
    it "routes to #example" do
      expect(get: "/import_plan_lots/example").to route_to("import_plan_lots#example")
    end
  end
end
