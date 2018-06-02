require "spec_helper"

describe CartLotsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cart_lots").to route_to("cart_lots#index")
    end

    it "routes to #create" do
      expect(post: "/cart_lots").to route_to("cart_lots#create")
    end

    it "routes to #clear" do
      expect(delete: "/cart_lots/clear").to route_to("cart_lots#clear")
    end

    it "routes to #destroy" do
      expect(delete: "/cart_lots/1").to route_to("cart_lots#destroy", id: "1")
    end
  end
end
