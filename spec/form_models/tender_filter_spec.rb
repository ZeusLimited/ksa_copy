require 'spec_helper'

describe TenderFilter do
  describe '#additional_search?' do
    let(:attributes) do
      {
        years: instance_of(String),
        customers: instance_of(String),
        organizers: instance_of(String),
        tender_types: instance_of(String),
        directions: instance_of(String),
        statuses: instance_of(String),
        search_by_name: instance_of(String),
        search_by_num: instance_of(String),
        search_by_gkpz_num: instance_of(String),
        by_winner: instance_of(String),
      }
    end
    it "additional attributes are absent" do
      t = TenderFilter.new(attributes)
      expect(t.additional_search?).to be false
    end

    context "additional attribute is present" do
      it_should_behave_like "additional attribute", :subject_types
      it_should_behave_like "additional attribute", :search_by_contract_nums
      it_should_behave_like "additional attribute", :etp_addresses
      it_should_behave_like "additional attribute", :monitor_services
      it_should_behave_like "additional attribute", :announce_date_begin
      it_should_behave_like "additional attribute", :announce_date_end
      it_should_behave_like "additional attribute", :wp_solutions
      it_should_behave_like "additional attribute", :consumers
      it_should_behave_like "additional attribute", :etp_num
      it_should_behave_like "additional attribute", :wp_date_begin
      it_should_behave_like "additional attribute", :wp_date_end
      it_should_behave_like "additional attribute", :contract_date_begin
      it_should_behave_like "additional attribute", :contract_date_end
      it_should_behave_like "additional attribute", :bidders
      it_should_behave_like "additional attribute", :start_cost
      it_should_behave_like "additional attribute", :end_cost
      it_should_behave_like "additional attribute", :start_tender_cost
      it_should_behave_like "additional attribute", :end_tender_cost
      it_should_behave_like "additional attribute", :sme_types
      it_should_behave_like "additional attribute", :regulation_items
      it_should_behave_like "additional attribute", :order1352
      it_should_behave_like "additional attribute", :okdp
      it_should_behave_like "additional attribute", :okved
      it_should_behave_like "additional attribute", :users
    end
  end
end
