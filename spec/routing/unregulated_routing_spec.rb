require "spec_helper"

describe UnregulatedController, type: :routing do
  describe "routing" do
    path = '/unregulated'

    it "routes to #new" do
      expect(get: "#{path}/new").to route_to("unregulated#new")
    end

    it "routes to #create" do
      expect(post: path).to route_to("unregulated#create")
    end

    it "routes to #edit" do
      expect(get: "#{path}/1/edit").to route_to("unregulated#edit", id: '1')
    end

    it "routes to #update" do
      expect(patch: "#{path}/1").to route_to("unregulated#update", id: '1')
    end
  end
end
