require 'spec_helper'

describe Criterion do
  it "reorder" do
    mas_in = %w(2. 1. 1.1.2. 1.1.1. 1.1. 1.2. 2.1.)
    mas_out = %w(1. 1.1. 1.1.1. 1.1.2. 1.2. 2. 2.1.)

    mas_in.each { |n| FactoryGirl.create(:criterion, list_num: n) }
    Criterion.reorder(Criterion.all)
    expect(Criterion.order(:position).pluck(:list_num)).to eq(mas_out)
  end

  it { expect(Criterion.new(list_num: "1.1", name: "xxx").fullname).to eq("1.1 xxx") }
end
