require "spec_helper"

describe ContractExpiredsController, type: :routing do
  describe "routing" do
    path = '/offers/1/contract_expired'
    def_params = { offer_id: '1' }

    it "routes to #edit" do
      expect(get: "#{path}/edit").to route_to("contract_expireds#edit", def_params)
    end

    it "routes to #update" do
      expect(put: path).to route_to("contract_expireds#update", def_params)
    end
  end
end
