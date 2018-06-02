require "spec_helper"

describe TenderRequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/tender_requests").to route_to("tender_requests#index", tender_id: "1")
    end

    it "routes to #new" do
      expect(get: "/tenders/1/tender_requests/new").to route_to("tender_requests#new", tender_id: "1")
    end

    it "routes to #show" do
      expect(get: "/tenders/1/tender_requests/1").to route_to("tender_requests#show", tender_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/tender_requests/1/edit").to route_to("tender_requests#edit", tender_id: "1", id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/tender_requests").to route_to("tender_requests#create", tender_id: "1")
    end

    it "routes to #update" do
      expect(put: "/tenders/1/tender_requests/1").to route_to("tender_requests#update", tender_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/tender_requests/1").to route_to("tender_requests#destroy", tender_id: "1", id: "1")
    end
  end
end
