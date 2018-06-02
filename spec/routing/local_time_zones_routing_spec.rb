require "spec_helper"

describe LocalTimeZonesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/local_time_zones").to route_to("local_time_zones#index")
    end

    it "routes to #new" do
      expect(get: "/local_time_zones/new").to route_to("local_time_zones#new")
    end

    it "routes to #show" do
      expect(get: "/local_time_zones/1").to route_to("local_time_zones#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/local_time_zones/1/edit").to route_to("local_time_zones#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/local_time_zones").to route_to("local_time_zones#create")
    end

    it "routes to #update" do
      expect(put: "/local_time_zones/1").to route_to("local_time_zones#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/local_time_zones/1").to route_to("local_time_zones#destroy", id: "1")
    end
  end
end
