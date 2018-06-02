require 'spec_helper'

describe TenderDecorator do
  describe "#oos_b2b_title" do
    it "always return value" do
      tender = build(:tender).decorate
      allow(tender).to receive(:link_to_oos).and_return('/')
      allow(tender).to receive(:link_to_etp).and_return('/')
      expect(tender.oos_b2b_title).to eq(
        I18n.t('tender_decorator.oos_b2b_title', num: tender.num, link_to_oos: '/', link_to_b2b: '/')
      )
    end
  end

  describe "#link_to_etp" do
    context "no links" do
      it "return no if etp_num.nil" do
        tender = build(:tender, etp_num: nil).decorate
        expect(tender.link_to_etp).to eq("нет")
      end
      it "return etp_num if other etp" do
        tender = build(:tender, etp_num: "123", etp_address_id: -1).decorate
        expect(tender.link_to_etp).to eq("123")
      end
    end

    context "has link" do
      it "link_to_b2b if b2b" do
        tender = build(:tender, :etp_b2b, etp_num: "123").decorate
        expect(tender).to receive(:link_to_b2b)

        tender.link_to_etp
      end
    end
  end

  describe '#link_to_b2b' do
    it "for tenders" do
      tender = build(:tender, :ook, :etp_b2b, etp_num: "123").decorate
      expect(tender.link_to_b2b).to match(/view_tender.html/)
    end
    it "for other types" do
      tender = build(:tender, :ozp, :etp_b2b, etp_num: "123").decorate
      expect(tender.link_to_b2b).to match(/view.html/)
    end
  end

  describe "#title_single_source" do
    it "title for raoesv" do
      tender = build(:tender).decorate
      allow(tender).to receive(:link_to_oos).and_return(eis = '/')
      expect(tender.title_single_source).to eq(
        I18n.t('tender_decorator.title_single_source',
               num: tender.num,
               date: tender.announce_date,
               link_to_eis: eis)
      )
    end
  end
end
