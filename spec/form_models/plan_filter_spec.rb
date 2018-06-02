# frozen_string_literal: true

require 'spec_helper'

describe PlanFilter do
  let(:user) { create(:user_user) }
  subject { PlanFilter.new }
  describe "#search_excel" do
    it "call a bunch of methods" do
      expect(subject).to receive_message_chain(:filter, :joins, :order, :select)
        .with(no_args)
        .with(PlanFilter::EXCEL_JOINS)
        .with(instance_of(String))
        .with(instance_of(String))
      subject.search_excel
    end
  end

  describe "#search_excel_lot" do
    it "call a bunch of methods" do
      expect(subject).to receive_message_chain(:filter, :joins, :order, :select, :group)
        .with(no_args)
        .with(PlanFilter::EXCEL_JOINS)
        .with(instance_of(String))
        .with(instance_of(String))
        .with(instance_of(String))
      subject.search_excel_lot
    end
  end

  describe "#additional_search?" do
    context "additional attribute is present" do
      it_should_behave_like "additional attribute", :date_begin
      it_should_behave_like "additional attribute", :date_end
      it_should_behave_like "additional attribute", :organizers
      it_should_behave_like "additional attribute", :monitor_services
      it_should_behave_like "additional attribute", :etp_addresses
      it_should_behave_like "additional attribute", :subject_types
      it_should_behave_like "additional attribute", :declared
      it_should_behave_like "additional attribute", :consumers
      it_should_behave_like "additional attribute", :control_lots
      it_should_behave_like "additional attribute", :state
      it_should_behave_like "additional attribute", :gkpz_on_date_begin
      it_should_behave_like "additional attribute", :gkpz_on_date_end
      it_should_behave_like "additional attribute", :bidders
      it_should_behave_like "additional attribute", :start_cost
      it_should_behave_like "additional attribute", :end_cost
      it_should_behave_like "additional attribute", :sme_types
      it_should_behave_like "additional attribute", :regulation_items
      it_should_behave_like "additional attribute", :order1352
      it_should_behave_like "additional attribute", :okdp
      it_should_behave_like "additional attribute", :okved
    end
  end

  describe 'selected_lots' do
    before(:example) { allow_any_instance_of(PlanLot).to receive(:nmcd_file) }
    let(:gkpz_year) { Faker::Date.between(2.days.ago, Date.today).year }
    let(:plan_filter_params) { { years: gkpz_year, current_user: user } }
    let!(:plan_lot) { create(:plan_lot, gkpz_year: gkpz_year) }

    context 'when selected lots true' do
      it 'set lots to user' do
        PlanFilter.new(plan_filter_params.merge(selected_lots: '1'))
        expect(user.plan_lots).to include(plan_lot)
      end
    end

    context 'when selected lots false' do
      it 'not set lots to user' do
        PlanFilter.new(plan_filter_params.merge(selected_lots: '0'))
        expect(user.plan_lots).to_not include(plan_lot)
      end
    end
  end
end
