require "spec_helper"

describe ContractorsController, type: :routing do
  describe "routing" do
    it "routes to #search" do
      expect(get: "/contractors/search").to route_to("contractors#search")
    end

    it "routes to #change_status" do
      expect(patch: "/contractors/1/change_status").to route_to("contractors#change_status", id: "1")
    end

    it "routes to #index" do
      expect(get: "/contractors").to route_to("contractors#index")
    end

    it "routes to #new" do
      expect(get: "/contractors/new").to route_to("contractors#new")
    end

    it "routes to #show" do
      expect(get: "/contractors/1").to route_to("contractors#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/contractors/1/edit").to route_to("contractors#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/contractors").to route_to("contractors#create")
    end

    it "routes to #update" do
      expect(patch: "/contractors/1").to route_to("contractors#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/contractors/1").to route_to("contractors#destroy", id: "1")
    end
  end
end
