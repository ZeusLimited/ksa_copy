require "spec_helper"

RSpec.describe RegulationItemsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get: "/regulation_items").to route_to("regulation_items#index")
    end

    it "routes to #new" do
      expect(get: "/regulation_items/new").to route_to("regulation_items#new")
    end

    it "routes to #edit" do
      expect(get: "/regulation_items/1/edit").to route_to("regulation_items#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/regulation_items").to route_to("regulation_items#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/regulation_items/1").to route_to("regulation_items#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/regulation_items/1").to route_to("regulation_items#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/regulation_items/1").to route_to("regulation_items#destroy", id: "1")
    end

    it "routes to #for_type" do
      expect(get: "/regulation_items/for_type").to route_to("regulation_items#for_type")
    end
  end
end
