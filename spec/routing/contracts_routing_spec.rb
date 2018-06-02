require "spec_helper"

describe ContractsController, type: :routing do
  describe "routing" do
    it "routes to #additional_search" do
      expect(get: '/offers/1/contract/additional_search').to route_to('contracts#additional_search', offer_id: '1')
    end

    it "routes to #additional_search" do
      expect(get: '/offers/1/contract/additional_info').to route_to('contracts#additional_info', offer_id: '1')
    end

    it "routes to #new" do
      expect(get: "/offers/1/contract/new").to route_to("contracts#new", offer_id: '1')
    end

    it "routes to #show" do
      expect(get: "/offers/1/contract").to route_to("contracts#show", offer_id: '1')
    end

    it "routes to #edit" do
      expect(get: "/offers/1/contract/edit").to route_to("contracts#edit", offer_id: '1')
    end

    it "routes to #create" do
      expect(post: "/offers/1/contract").to route_to("contracts#create", offer_id: '1')
    end

    it "routes to #update" do
      expect(patch: "/offers/1/contract").to route_to("contracts#update", offer_id: '1')
    end

    it "routes to #destroy" do
      expect(delete: "/offers/1/contract").to route_to("contracts#destroy", offer_id: '1')
    end
  end
end
