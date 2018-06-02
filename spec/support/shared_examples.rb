shared_examples "additional attribute" do |attribute|
  let(:filter) { described_class.new(attribute => instance_of(String)) }
  describe "present" do
    it "#{attribute}" do
      expect(filter.additional_search?).to be true
    end
  end
end
