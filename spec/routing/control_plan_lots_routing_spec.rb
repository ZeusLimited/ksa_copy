require "spec_helper"

describe ControlPlanLotsController, type: :routing do
  describe "routing" do
    it "routes to #create_list" do
      expect(post: "/control_plan_lots/create_list").to route_to("control_plan_lots#create_list")
    end

    it "routes to #new" do
      expect(delete: "/control_plan_lots/delete_list").to route_to("control_plan_lots#delete_list")
    end
  end
end
