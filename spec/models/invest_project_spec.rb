require 'spec_helper'

describe InvestProject do
  describe 'validate :power_presence' do
    let(:invest_project) do FactoryGirl.build(:invest_project,
                                              power_elec_gen: nil,
                                              power_elec_net: nil,
                                              power_substation: nil,
                                              power_thermal_gen: nil,
                                              power_thermal_net: nil) end
    let(:message) { "Должны быть указаны параметры объекта, на который будут списаны затраты (мощность)." }

    it do
      invest_project.valid?
      expect(invest_project.errors[:base]).to include(message)
    end

    it do
      invest_project.power_elec_gen = 123
      invest_project.valid?
      expect(invest_project.errors[:base]).not_to include(message)
    end

    it do
      invest_project.power_elec_net = 123
      invest_project.valid?
      expect(invest_project.errors[:base]).not_to include(message)
    end

    it do
      invest_project.power_substation = 123
      invest_project.valid?
      expect(invest_project.errors[:base]).not_to include(message)
    end

    it do
      invest_project.power_thermal_gen = 123
      invest_project.valid?
      expect(invest_project.errors[:base]).not_to include(message)
    end

    it do
      invest_project.power_thermal_net = 123
      invest_project.valid?
      expect(invest_project.errors[:base]).not_to include(message)
    end
  end

  describe '#power_name' do
    it "full" do
      ip = FactoryGirl.build(:invest_project,
                             power_elec_gen: 1,
                             power_elec_net: 1,
                             power_substation: 1,
                             power_thermal_gen: 1,
                             power_thermal_net: 1)
      expect(ip.power_name).to eq("1.0 МВт; 1.0 Гкал/ч; 1.0 км; 1.0 км; 1.0 МВА")
    end

    it "not full" do
      ip = FactoryGirl.build(:invest_project,
                             power_elec_gen: 1,
                             power_substation: 1,
                             power_thermal_net: 1)
      expect(ip.power_name).to include("1.0 МВт", "1.0 км", "1.0 МВА")
    end
  end

  it '#fullname' do
    ip = FactoryGirl.build(:invest_project, num: "123", name: "abc", object_name: "def")
    expect(ip.fullname).to eq("123 abc / def")
  end

end
