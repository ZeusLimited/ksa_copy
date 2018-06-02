require "spec_helper"

describe Account::ProfileController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/account/profile").to route_to("account/profile#show")
    end

    it "routes to #edit" do
      expect(get: "/account/profile/edit").to route_to("account/profile#edit")
    end

    it "routes to #update" do
      expect(patch: "/account/profile").to route_to("account/profile#update")
    end

    it "routes to #edit_password" do
      expect(get: "/account/profile/edit_password").to route_to("account/profile#edit_password")
    end

    it "routes to #update_password" do
      expect(patch: "/account/profile/update_password").to route_to("account/profile#update_password")
    end
  end
end
