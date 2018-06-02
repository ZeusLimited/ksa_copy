require 'spec_helper'

describe RegulationItemDecorator do
  let(:regulation_item) do
    create(:regulation_item, is_actual: true, tender_type_ids: [Constants::TenderTypes::OOK]).decorate
  end

  it "#tender_type_names" do
    expect(regulation_item.tender_type_names).to eq(Dictionary.where(ref_id: Constants::TenderTypes::OOK).map(&:name))
  end

  it "#row_class" do
    expect(regulation_item.row_class).to eq('success')
  end
end
