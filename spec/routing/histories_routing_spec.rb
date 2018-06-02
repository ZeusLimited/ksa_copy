require "spec_helper"

describe HistoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/histories").to route_to("histories#index")
    end
  end
end
