require "spec_helper"

describe ExpertOpinionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tenders/1/expert_opinions").to route_to("expert_opinions#index", tender_id: "1")
    end

    it "routes to #show_draft" do
      expect(get: "/tenders/1/expert_opinions/1/show_draft").to route_to("expert_opinions#show_draft",
                                                                         tender_id: "1",
                                                                         id: "1")
    end

    it "routes to #edit_draft" do
      expect(get: "/tenders/1/expert_opinions/1/edit_draft").to route_to("expert_opinions#edit_draft",
                                                                         tender_id: "1",
                                                                         id: "1")
    end

    it "routes to #update_draft" do
      expect(post: "/tenders/1/expert_opinions/1/update_draft").to route_to("expert_opinions#update_draft",
                                                                            tender_id: "1",
                                                                            id: "1")
    end
  end
end
