require 'spec_helper'

describe TendersHelper do
  it "link to plan_lot" do
    lot = FactoryGirl.create(:lot_with_spec, gkpz_year: 2013, plan_lot:  FactoryGirl.create(:plan_lot_with_specs, :agreement, num_tender: 1, num_lot: 1))
    expect(helper.link_to_plan_lot(lot)).to have_link("1.1 по ГКПЗ 2013", href: plan_lot_path(lot.plan_lot_id))
  end
end
