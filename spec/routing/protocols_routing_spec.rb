require "spec_helper"

describe ProtocolsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/protocols").to route_to("protocols#index")
    end

    it "routes to #new" do
      expect(get: "/protocols/new").to route_to("protocols#new")
    end

    it "routes to #show" do
      expect(get: "/protocols/1").to route_to("protocols#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/protocols/1/edit").to route_to("protocols#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/protocols").to route_to("protocols#create")
    end

    it "routes to #update" do
      expect(put: "/protocols/1").to route_to("protocols#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/protocols/1").to route_to("protocols#destroy", id: "1")
    end

    it "routes to #merge_new" do
      expect(get: "/protocols/merge_new").to route_to("protocols#merge_new")
    end

    it "routes to #merge_create" do
      expect(post: "/protocols/merge_create").to route_to("protocols#merge_create")
    end
  end
end
