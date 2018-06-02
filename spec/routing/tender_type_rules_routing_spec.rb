require "spec_helper"

describe TenderTypeRulesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tender_type_rules").to route_to("tender_type_rules#index")
    end

    it "routes to #edit_all" do
      expect(get: "/tender_type_rules/edit_all").to route_to("tender_type_rules#edit_all")
    end

    it "routes to #update_all" do
      expect(patch: "/tender_type_rules/update_all").to route_to("tender_type_rules#update_all")
    end
  end
end
