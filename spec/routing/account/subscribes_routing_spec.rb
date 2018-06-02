require "spec_helper"

describe Account::SubscribesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/account/subscribes").to route_to("account/subscribes#index")
    end

    it "routes to #new_list" do
      expect(get: "/account/subscribes/new_list").to route_to("account/subscribes#new_list")
    end

    it "routes to #edit_list" do
      expect(get: "/account/subscribes/edit_list").to route_to("account/subscribes#edit_list")
    end

    it "routes to #create_list" do
      expect(post: "/account/subscribes/create_list").to route_to("account/subscribes#create_list")
    end

    it "routes to #update_list" do
      expect(post: "/account/subscribes/update_list").to route_to("account/subscribes#update_list")
    end

    it "routes to #delete_list" do
      expect(delete: "/account/subscribes/delete_list").to route_to("account/subscribes#delete_list")
    end

    it "routes to #push_to_session" do
      expect(post: "/account/subscribes/push_to_session").to route_to("account/subscribes#push_to_session")
    end

    it "routes to #pop_from_session" do
      expect(post: "/account/subscribes/pop_from_session").to route_to("account/subscribes#pop_from_session")
    end
  end
end
