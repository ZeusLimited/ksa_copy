require "spec_helper"

describe ContractTerminationsController, type: :routing do
  describe "routing" do
    path = '/contracts/1/contract_termination'
    def_params = { contract_id: '1' }

    it "routes to #new" do
      expect(get: "#{path}/new").to route_to("contract_terminations#new", def_params)
    end

    it "routes to #show" do
      expect(get: path).to route_to("contract_terminations#show", def_params)
    end

    it "routes to #edit" do
      expect(get: "#{path}/edit").to route_to("contract_terminations#edit", def_params)
    end

    it "routes to #create" do
      expect(post: path).to route_to("contract_terminations#create", def_params)
    end

    it "routes to #update" do
      expect(put: path).to route_to("contract_terminations#update", def_params)
    end

    it "routes to #destroy" do
      expect(delete: path).to route_to("contract_terminations#destroy", def_params)
    end
  end
end
