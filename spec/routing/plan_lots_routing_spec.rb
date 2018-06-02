require "spec_helper"

describe PlanLotsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/plan_lots").to route_to("plan_lots#index")
    end

    it "routes to #create" do
      expect(post: "/plan_lots").to route_to("plan_lots#create")
    end

    it "routes to #new" do
      expect(get: "/plan_lots/new").to route_to("plan_lots#new")
    end

    it "routes to #edit" do
      expect(get: "/plan_lots/1/edit").to route_to("plan_lots#edit", id: "1")
    end

    it "routes to #show" do
      expect(get: "/plan_lots/1").to route_to("plan_lots#show", id: "1")
    end

    it "routes to #update" do
      expect(patch: "/plan_lots/1").to route_to("plan_lots#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/plan_lots/1").to route_to("plan_lots#destroy", id: "1")
    end

    it "routes to #edit_without_history" do
      expect(get: "/plan_lots/1/edit_without_history").to route_to("plan_lots#edit_without_history", id: "1")
    end

    it "routes to #update_without_history" do
      expect(patch: "/plan_lots/1/update_without_history").to route_to("plan_lots#update_without_history", id: "1")
    end

    it "routes to #additional_search" do
      expect(get: "/plan_lots/additional_search").to route_to("plan_lots#additional_search")
    end

    it "routes to #additional_info" do
      expect(get: "/plan_lots/additional_info").to route_to("plan_lots#additional_info")
    end

    it "routes to #reset" do
      expect(get: "/plan_lots/reset").to route_to("plan_lots#reset")
    end

    it "routes to #import_excel" do
      expect(get: "/plan_lots/import_excel").to route_to("plan_lots#import_excel")
    end

    it "routes to #import" do
      expect(post: "/plan_lots/import").to route_to("plan_lots#import")
    end

    it "routes to #import_lots" do
      expect(get: "/plan_lots/import_lots").to route_to("plan_lots#import_lots")
    end

    it "routes to #upload_excel" do
      expect(post: "/plan_lots/upload_excel").to route_to("plan_lots#upload_excel")
    end

    it "routes to #next_free_number" do
      expect(post: "/plan_lots/next_free_number").to route_to("plan_lots#next_free_number")
    end

    it "routes to #submit_approval" do
      expect(patch: "/plan_lots/submit_approval").to route_to("plan_lots#submit_approval")
    end

    it "routes to #return_for_revision" do
      expect(patch: "/plan_lots/return_for_revision").to route_to("plan_lots#return_for_revision")
    end

    it "routes to #destroy_version" do
      expect(delete: "/plan_lots/1/destroy_version").to route_to("plan_lots#destroy_version", id: "1")
    end

    it "routes to #destroy_current_version_user" do
      expect(patch: "/plan_lots/destroy_current_version_user").to route_to("plan_lots#destroy_current_version_user")
    end

    it "routes to #agree" do
      expect(patch: "/plan_lots/agree").to route_to("plan_lots#agree")
    end

    it "routes to #pre_confirm_sd" do
      expect(patch: "/plan_lots/pre_confirm_sd").to route_to("plan_lots#pre_confirm_sd")
    end

    it "routes to #cancel_pre_confirm_sd" do
      expect(patch: "/plan_lots/cancel_pre_confirm_sd").to route_to("plan_lots#cancel_pre_confirm_sd")
    end

    it "routes to #reform_okveds" do
      expect(get: "/plan_lots/reform_okveds").to route_to("plan_lots#reform_okveds")
    end

    let(:guid_hex) { UUIDTools::UUID.parse_raw(SecureRandom.random_bytes(16)).hexdigest  }

    it "routes to #history_lot" do
      expect(get: "/plan_lot_history/#{guid_hex}").to route_to("plan_lots#history_lot", guid: guid_hex)
    end

    it "routes to #history_lot_full" do
      expect(get: "/plan_lot_history_full/#{guid_hex}").to route_to("plan_lots#history_lot_full", guid: guid_hex)
    end

    it "routes to #history_spec" do
      expect(get: "/plan_spec_history/#{guid_hex}").to route_to("plan_lots#history_spec", guid: guid_hex)
    end

    it "routes to #preselection_info" do
      expect(get: "/plan_lots/1/preselection_info").to route_to("plan_lots#preselection_info", id: "1")
    end

    it "routes to #root" do
      expect(get: "/").to route_to("plan_lots#index")
    end
  end
end
