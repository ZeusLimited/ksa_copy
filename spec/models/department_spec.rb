require 'spec_helper'

shared_examples "rank_departments" do |class_method, filter|
  it "was receive with #{filter}" do
    expect(described_class).to receive(:rank_array).with(anything, true, filter)
    described_class.send(class_method)
  end
end

describe Department do
  it_should_behave_like "rank_departments", :consumers_by_root, is_consumer: true
  it_should_behave_like "rank_departments", :customers_by_root, is_customer: true
  it_should_behave_like "rank_departments", :organizers_by_root, is_organizer: true

  describe ".by_root" do
    let(:dept) { create(:department) }
    let(:child_dept) { create(:department, :child, parent_dept_id: dept.id) }
    subject { described_class.by_root(dept) }
    it "return child elements" do
      allow(dept).to receive(:subtree_ids) { [child_dept.id] }
      expect(subject).to eq([child_dept])
    end
    it "return nothing" do
      allow(dept).to receive(:subtree_ids) {}
      expect(subject).to be_empty
    end
  end
end
