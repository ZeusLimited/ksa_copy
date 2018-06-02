require "spec_helper"

describe DocTakersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/doc_takers").to route_to("doc_takers#index", tender_id: "1")
    end

    it "routes to #create" do
      expect(post: "/tenders/1/doc_takers").to route_to("doc_takers#create", tender_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/tenders/1/doc_takers/1").to route_to("doc_takers#destroy", tender_id: "1", id: "1")
    end
  end
end
