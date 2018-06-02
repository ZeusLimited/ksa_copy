require "spec_helper"

describe SubContractorsController, type: :routing do
  describe "routing" do
    path = '/contracts/1/sub_contractors'
    default = { contract_id: '1' }

    it("routes to #index") { expect(get: path).to route_to("sub_contractors#index", default) }
    it("routes to #create") { expect(post: path).to route_to("sub_contractors#create", default) }
    it("routes to #new") { expect(get: "#{path}/new").to route_to("sub_contractors#new", default) }
    it("routes to #edit") { expect(get: "#{path}/1/edit").to route_to("sub_contractors#edit", default.merge(id: '1')) }
    it("routes to #show") { expect(get: "#{path}/1").to route_to("sub_contractors#show", default.merge(id: '1')) }
    it("routes to #update") do
      expect(patch: "#{path}/1").to route_to("sub_contractors#update", default.merge(id: '1'))
    end
    it("routes to #destroy") do
      expect(delete: "#{path}/1").to route_to("sub_contractors#destroy", default.merge(id: '1'))
    end
  end
end
