require 'spec_helper'

RSpec.describe ContractDecorator do

  let(:contract) { build(:contract).decorate }

  describe "#show_template" do
    context "return show because tender is" do
      it "competitive" do
        allow(contract).to receive_message_chain(:tender, :only_source?).and_return false
        expect(contract.show_template).to eq(:show)
      end
    end
  end

end
