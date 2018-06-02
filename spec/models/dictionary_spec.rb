require 'spec_helper'

describe Dictionary do
  describe '#color' do
    context "return nil" do
      it "stylename_html is nil" do
        object = build(:dictionary, stylename_html: nil)
        expect(object.color).to eq(nil)
      end

      it "stylename_html doesn't contain background-color" do
        object = build(:dictionary, stylename_html: "MyString")
        expect(object.color).to eq(nil)
      end
    end

    it "color has found in stylename_html" do
      object = build(:dictionary, stylename_html: "background-color: #32FF22;")
      expect(object.color).to eq("#32FF22")
    end
  end

  describe "order1352 scope" do
    it "call a bunch of methods" do
      expect(Dictionary).to receive_message_chain(:where, :order)
        .with(ref_type: 'Order1352').with(:position)
      Dictionary.order1352
    end
  end

  describe "order1352_without_not_select scope" do
    it "call a bunch of methods" do
      expect(Dictionary).to receive_message_chain(:where, :where, :not, :order)
        .with(ref_type: 'Order1352').with(no_args).with(ref_id: Order1352::NOT_SELECT).with(:position)
      Dictionary.order1352_without_not_select
    end
  end

  describe "order1352_special" do
    it "call a bunch of methods" do
      reg_item = create(:regulation_item)
      expect(Dictionary).to receive_message_chain(:joins, :where)
        .with(:regulation_items)
        .with(regulation_items: { id: reg_item.id })
      Dictionary.order1352_special(reg_item.id)
    end
    it "get value" do
      order = Dictionary.order1352.first
      reg_item = create(:regulation_item, dictionaries: [order])
      expect(Dictionary.order1352_special(reg_item.id)).to eq([order])
    end
    it 'not include not_select item' do
      expect(Dictionary.order1352.order1352_special(nil).pluck(:ref_id)).to_not include(Order1352::NOT_SELECT)
    end
  end

  describe '.etp_addresses_without' do
    it 'return all etp adresses without specific adress' do
      address = Dictionary.etp_addresses.take
      expect(Dictionary.etp_addresses_without(address.ref_id)).not_to include address
    end
  end
end
