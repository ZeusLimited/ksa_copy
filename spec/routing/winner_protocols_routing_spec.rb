require "spec_helper"

describe WinnerProtocolsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/winner_protocols").to route_to("winner_protocols#index", tender_id: "1")
    end

    it "routes to #new" do
      expect(get: "/tenders/1/winner_protocols/new").to route_to("winner_protocols#new", tender_id: "1")
    end

    it "routes to #show" do
      expect(get: "/tenders/1/winner_protocols/1").to route_to("winner_protocols#show", tender_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/winner_protocols/1/edit").to route_to("winner_protocols#edit", tender_id: "1", id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/winner_protocols").to route_to("winner_protocols#create", tender_id: "1")
    end

    it "routes to #update" do
      expect(put: "/tenders/1/winner_protocols/1").to route_to("winner_protocols#update", tender_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/winner_protocols/1").to route_to("winner_protocols#destroy", tender_id: "1", id: "1")
    end

    it "routes to #update_confirm_date" do
      expect(patch: "/tenders/1/winner_protocols/1/update_confirm_date").to route_to("winner_protocols#update_confirm_date", tender_id: "1", id: "1")
    end
  end
end
