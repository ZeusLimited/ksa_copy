require 'spec_helper'

describe OpenProtocol do
  it "is invalid without a clerk_id" do
    record = FactoryGirl.build(:open_protocol, clerk_id: nil)
    record.valid?
    expect(record.errors[:clerk_id].size).to eq(1)
  end

  it "does not allow duplicate tender numbers per protocol" do
    tender = create(:tender)
    create(:open_protocol, tender: tender)
    record = build(:open_protocol, tender: tender)
    record.valid?
    expect(record.errors[:tender_id].size).to eq(1)
  end
end
