require "spec_helper"

describe ContractorsRenameController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/contractors/1/rename/new").to route_to("contractors_rename#new", contractor_id: "1")
    end

    it "routes to #create" do
      expect(post: "/contractors/1/rename").to route_to("contractors_rename#create", contractor_id: "1")
    end
  end
end
