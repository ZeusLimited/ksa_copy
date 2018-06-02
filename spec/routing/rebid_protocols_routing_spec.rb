require "spec_helper"

describe RebidProtocolsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/rebid_protocols").to route_to("rebid_protocols#index", tender_id: '1')
    end

    it "routes to #new" do
      expect(get: "/tenders/1/rebid_protocols/new").to route_to("rebid_protocols#new", tender_id: '1')
    end

    it "routes to #show" do
      expect(get: "/tenders/1/rebid_protocols/1").to route_to("rebid_protocols#show", tender_id: '1', id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/rebid_protocols/1/edit").to route_to("rebid_protocols#edit", tender_id: '1', id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/rebid_protocols").to route_to("rebid_protocols#create", tender_id: '1')
    end

    it "routes to #update" do
      expect(put: "/tenders/1/rebid_protocols/1").to route_to("rebid_protocols#update", tender_id: '1', id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/rebid_protocols/1").to route_to("rebid_protocols#destroy", tender_id: '1', id: "1")
    end

    it "routes to #present_members" do
      expect(post: "/tenders/1/rebid_protocols/present_members").to route_to("rebid_protocols#present_members",
                                                                             tender_id: '1')
    end
  end
end
