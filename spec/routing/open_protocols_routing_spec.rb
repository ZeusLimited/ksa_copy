require "spec_helper"

describe OpenProtocolsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/tenders/1/open_protocols/new").to route_to("open_protocols#new", tender_id: "1")
    end

    it "routes to #show" do
      expect(get: "/tenders/1/open_protocols/1").to route_to("open_protocols#show", tender_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/open_protocols/1/edit").to route_to("open_protocols#edit", tender_id: "1", id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/open_protocols").to route_to("open_protocols#create", tender_id: "1")
    end

    it "routes to #update" do
      expect(put: "/tenders/1/open_protocols/1").to route_to("open_protocols#update", tender_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/open_protocols/1").to route_to("open_protocols#destroy", tender_id: "1", id: "1")
    end

    it "routes to #present_members" do
      expect(post: "/tenders/1/open_protocols/present_members").to route_to("open_protocols#present_members",
                                                                            tender_id: "1")
    end
  end
end
