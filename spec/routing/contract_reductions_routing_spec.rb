require "spec_helper"

describe ContractReductionsController, type: :routing do
  describe "routing" do
    path = '/contracts/1/contract_reductions'
    def_params = { contract_id: '1' }

    it "routes to #index" do
      expect(get: path).to route_to("contract_reductions#index", def_params)
    end

    it "routes to #new" do
      expect(get: "#{path}/new").to route_to("contract_reductions#new", def_params)
    end

    it "routes to #show" do
      expect(get: "#{path}/1").to route_to("contract_reductions#show", def_params.merge(id: '1'))
    end

    it "routes to #edit" do
      expect(get: "#{path}/1/edit").to route_to("contract_reductions#edit", def_params.merge(id: '1'))
    end

    it "routes to #create" do
      expect(post: path).to route_to("contract_reductions#create", def_params)
    end

    it "routes to #update" do
      expect(put: "#{path}/1").to route_to("contract_reductions#update", def_params.merge(id: '1'))
    end

    it "routes to #destroy" do
      expect(delete: "#{path}/1").to route_to("contract_reductions#destroy", def_params.merge(id: '1'))
    end
  end
end
