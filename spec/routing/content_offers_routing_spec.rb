require "spec_helper"

describe ContentOffersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/content_offers").to route_to("content_offers#index")
    end

    it "routes to #new" do
      expect(get: "/content_offers/new").to route_to("content_offers#new")
    end

    it "routes to #show" do
      expect(get: "/content_offers/1").to route_to("content_offers#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/content_offers/1/edit").to route_to("content_offers#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/content_offers").to route_to("content_offers#create")
    end

    it "routes to #update" do
      expect(put: "/content_offers/1").to route_to("content_offers#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/content_offers/1").to route_to("content_offers#destroy", id: "1")
    end
  end
end
