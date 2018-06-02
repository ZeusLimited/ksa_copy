require "spec_helper"

describe UserPlanLotsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/user_plan_lots").to route_to("user_plan_lots#index")
    end

    it "routes to #select_list" do
      expect(post: "/user_plan_lots/select_list").to route_to("user_plan_lots#select_list")
    end

    it "routes to #unselect_list" do
      expect(post: "/user_plan_lots/unselect_list").to route_to("user_plan_lots#unselect_list")
    end

    it "routes to #unselect_all" do
      expect(post: "/user_plan_lots/unselect_all").to route_to("user_plan_lots#unselect_all")
    end
  end
end
