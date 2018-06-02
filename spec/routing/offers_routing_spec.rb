require "spec_helper"

describe OffersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/bidders/1/offers").to route_to("offers#index", tender_id: "1", bidder_id: "1")
    end

    it "routes to #new" do
      expect(get: "/tenders/1/bidders/1/offers/new").to route_to("offers#new", tender_id: "1", bidder_id: "1")
    end

    it "routes to #show" do
      expect(get: "/tenders/1/bidders/1/offers/1").to route_to("offers#show", tender_id: "1", bidder_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/bidders/1/offers/1/edit").to route_to("offers#edit",
                                                                    tender_id: "1",
                                                                    bidder_id: "1",
                                                                    id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/bidders/1/offers").to route_to("offers#create", tender_id: "1", bidder_id: "1")
    end

    it "routes to #update" do
      expect(put: "/tenders/1/bidders/1/offers/1").to route_to("offers#update",
                                                               tender_id: "1",
                                                               bidder_id: "1",
                                                               id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/bidders/1/offers/1").to route_to("offers#destroy",
                                                                  tender_id: "1",
                                                                  bidder_id: "1",
                                                                  id: "1")
    end

    it "routes to #control" do
      expect(get: "/tenders/1/bidders/1/offers/control").to route_to("offers#control",
                                                                     tender_id: "1",
                                                                     bidder_id: "1")
    end

    it "routes to #add" do
      expect(post: "/tenders/1/bidders/1/offers/add").to route_to("offers#add", tender_id: "1", bidder_id: "1")
    end

    it "routes to #pickup" do
      expect(post: "/tenders/1/bidders/1/offers/pickup").to route_to("offers#pickup", tender_id: "1", bidder_id: "1")
    end
  end
end
