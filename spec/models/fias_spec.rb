require 'spec_helper'

describe Fias do
  describe ".by_ids" do
    let(:fias) { create(:fias) }
    let(:without_house) { create(:fias, houseid_hex: nil) }

    context "found object" do
      it "by two arguments" do
        expect(Fias.by_ids(fias.aoid_hex, fias.houseid_hex)).to eq([fias])
      end
      it "by one argument" do
        expect(Fias.by_ids(without_house.aoid_hex)).to eq([without_house])
      end
    end

    context "object is not found" do
      it "by one argument" do
        expect(Fias.by_ids(fias.aoid_hex)).to be_empty
      end
    end
  end
end
