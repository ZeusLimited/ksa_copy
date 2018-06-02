require "spec_helper"

describe Account::SettingsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/account/settings").to route_to("account/settings#show")
    end

    it "routes to #edit" do
      expect(get: "/account/settings/edit").to route_to("account/settings#edit")
    end

    it "routes to #update" do
      expect(patch: "/account/settings").to route_to("account/settings#update")
    end

    it "routes to #create" do
      expect(post: "/account/settings").to route_to("account/settings#create")
    end
  end
end
