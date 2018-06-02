require "spec_helper"

describe LotsController, type: :routing do
  describe "routing" do
    it "routes to #frame_info" do
      expect(get: "/tenders/1/lots/1/frame_info").to route_to("lots#frame_info", tender_id: '1', id: '1')
    end
  end
end
