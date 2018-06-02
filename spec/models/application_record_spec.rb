require 'spec_helper'

describe ApplicationRecord do
  describe ".multi_value_filter" do
    # subject { described_class.multi_value_filter(_ _) }
    it "return sql where clause by splitting the given string by ' '" do
      expect(described_class.multi_value_filter("pl.num_tender like ?", '1. 3')).to eq(
        "pl.num_tender like '1.%' OR pl.num_tender like '3%'"
      )
    end
    it "return sql where clause by splitting the given string by ','" do
      expect(described_class.multi_value_filter("pl.num_tender like ?", '1.,3')).to eq(
        "pl.num_tender like '1.%' OR pl.num_tender like '3%'"
      )
    end
  end
end
