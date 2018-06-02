require "spec_helper"

describe ResultProtocolsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/result_protocols").to route_to("result_protocols#index", tender_id: "1")
    end

    it "routes to #new" do
      expect(get: "/tenders/1/result_protocols/new").to route_to("result_protocols#new", tender_id: "1")
    end

    it "routes to #show" do
      expect(get: "/tenders/1/result_protocols/1").to route_to("result_protocols#show", tender_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/tenders/1/result_protocols/1/edit").to route_to("result_protocols#edit", tender_id: "1", id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/result_protocols").to route_to("result_protocols#create", tender_id: "1")
    end

    it "routes to #update" do
      expect(put: "/tenders/1/result_protocols/1").to route_to("result_protocols#update", tender_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/result_protocols/1").to route_to("result_protocols#destroy", tender_id: "1", id: "1")
    end

    it "routes to #sign" do
      expect(patch: "/tenders/1/result_protocols/1/sign").to route_to("result_protocols#sign", tender_id: "1", id: "1")
    end

    it "routes to #revoke_sign" do
      expect(patch: "/tenders/1/result_protocols/1/revoke_sign").to route_to("result_protocols#revoke_sign",
                                                                             tender_id: "1",
                                                                             id: "1")
    end
  end
end
