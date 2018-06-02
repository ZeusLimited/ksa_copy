require "spec_helper"

describe BiddersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/bidders").to route_to("bidders#index", tender_id: "1")
    end

    it "routes to #new" do
      expect(get: "/tenders/1/bidders/new").to route_to("bidders#new", tender_id: "1")
    end

    it "routes to #show" do
      expect(get: "/tenders/1/bidders/1").to route_to("bidders#show", tender_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/bidders/1/edit").to route_to("bidders#edit", tender_id: "1", id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/bidders").to route_to("bidders#create", tender_id: "1")
    end

    it "routes to #update" do
      expect(put: "/tenders/1/bidders/1").to route_to("bidders#update", tender_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/bidders/1").to route_to("bidders#destroy", tender_id: "1", id: "1")
    end

    it "routes to #map_by_lot" do
      expect(get: "/tenders/1/bidders/map_by_lot").to route_to("bidders#map_by_lot", tender_id: "1")
    end

    it "routes to #map_pivot" do
      expect(get: "/tenders/1/bidders/map_pivot").to route_to("bidders#map_pivot", tender_id: "1")
    end
  end
end
