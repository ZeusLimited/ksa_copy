require 'spec_helper'

describe ContractSpecification do
  it '#nds' do
    specification = FactoryGirl.create(:contract_specification, cost: 1000.50, cost_nds: 1200.60)
    expect(specification.nds).to eq(20.00)
  end

end
