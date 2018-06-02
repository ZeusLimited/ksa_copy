FactoryGirl.define do
  factory :okdp do
    code "Mystring"
    name "Mystring"
    ref_type 'OKDP'

    factory :okdp_level do
      before(:create) do |okdp|
        level_0 = create(:okdp)
        level_1 = create(:okdp, parent: level_0)
        okdp.parent = level_1
      end
    end

    factory :okdp_type_new do
      before(:create) do |okdp|
        level_0 = create(:okdp)
        level_1 = create(:okdp, parent: level_0)
        okdp.parent = level_1
      end
      ref_type 'OKPD2'
    end
  end
end
