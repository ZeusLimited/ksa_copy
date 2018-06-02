require 'spec_helper'

class Validatable
  include ActiveModel::Validations
  attr_accessor :some_date
  validates :some_date, workday: true
end

describe WorkdayValidator do
  it "be valid with an excited title" do
    o = Validatable.new
    o.some_date = Date.parse("2014-03-11")
    expect(o).to be_valid
  end

  it "be invalid with an unexcited title" do
    o = Validatable.new
    o.some_date = Date.parse("2014-03-10")
    expect(o).to be_invalid
  end
end
