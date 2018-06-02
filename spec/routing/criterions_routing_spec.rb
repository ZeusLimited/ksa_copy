require "spec_helper"

describe CriterionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/criterions").to route_to("criterions#index")
    end

    it "routes to #new" do
      expect(get: "/criterions/new").to route_to("criterions#new")
    end

    it "routes to #show" do
      expect(get: "/criterions/1").to route_to("criterions#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/criterions/1/edit").to route_to("criterions#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/criterions").to route_to("criterions#create")
    end

    it "routes to #update" do
      expect(put: "/criterions/1").to route_to("criterions#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/criterions/1").to route_to("criterions#destroy", id: "1")
    end
  end
end
