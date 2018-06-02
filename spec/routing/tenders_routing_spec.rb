require "spec_helper"

describe TendersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders").to route_to("tenders#index")
    end

    it "routes to #new" do
      expect(get: "/tenders/new").to route_to("tenders#new")
    end

    it "routes to #show" do
      expect(get: "/tenders/1").to route_to("tenders#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/edit").to route_to("tenders#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders").to route_to("tenders#create")
    end

    it "routes to #update" do
      expect(put: "/tenders/1").to route_to("tenders#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1").to route_to("tenders#destroy", id: "1")
    end

    it "routes to #copy" do
      expect(get: "/tenders/1/copy").to route_to("tenders#copy", id: "1")
    end

    it "routes to #show_bidder_requirements" do
      expect(get: "/tenders/1/show_bidder_requirements").to route_to("tenders#show_bidder_requirements", id: "1")
    end

    it "routes to #edit_bidder_requirements" do
      expect(get: "/tenders/1/edit_bidder_requirements").to route_to("tenders#edit_bidder_requirements", id: "1")
    end

    it "routes to #update_bidder_requirements" do
      expect(patch: "/tenders/1/update_bidder_requirements").to route_to("tenders#update_bidder_requirements", id: "1")
    end

    it "routes to #show_offer_requirements" do
      expect(get: "/tenders/1/show_offer_requirements").to route_to("tenders#show_offer_requirements", id: "1")
    end

    it "routes to #edit_offer_requirements" do
      expect(get: "/tenders/1/edit_offer_requirements").to route_to("tenders#edit_offer_requirements", id: "1")
    end

    it "routes to #update_offer_requirements" do
      expect(patch: "/tenders/1/update_offer_requirements").to route_to("tenders#update_offer_requirements", id: "1")
    end

    it "routes to #public" do
      expect(patch: "/tenders/1/public").to route_to("tenders#public", id: "1")
    end

    it "routes to #contracts" do
      expect(get: "/tenders/1/contracts").to route_to("tenders#contracts", id: "1")
    end
  end
end
