# frozen_string_literal: true

require 'spec_helper'

describe PlanLotDecorator do
  let(:object) { described_class.new(plan_lot) }
  let(:plan_lot) { create(:plan_lot) }

  describe '#customer_names' do
    subject { object.customer_names }

    let(:plan_lot) do
      build(:plan_lot, plan_specifications: [
        build(:plan_specification, customer: create(:department, name: name1)),
        build(:plan_specification, customer: create(:department, name: name2)),
      ])
    end
    let(:name1) { Faker::Lorem.unique.word }
    let(:name2) { Faker::Lorem.unique.word }

    context 'show names' do
      it { should eq [name1, name2] }
    end

    context 'uniq names' do
      let(:name2) { name1 }

      it { should eq [name1] }
    end
  end

  describe '#customer_shortnames, #consumer_shortnames' do
    %w[customer consumer].each do |relation|
      subject { object.public_send("#{relation}_shortnames") }

      let(:plan_lot) do
        build(:plan_lot, plan_specifications: [
          build(:plan_specification, relation => create(:department, shortname: name1)),
          build(:plan_specification, relation => create(:department, shortname: name2)),
        ])
      end
      let(:name1) { Faker::Lorem.unique.word }
      let(:name2) { Faker::Lorem.unique.word }

      context 'show names' do
        it { should eq [name1, name2] }
      end

      context 'uniq names' do
        let(:name2) { name1 }

        it { should eq [name1] }
      end
    end
  end

  describe '#etp' do
    subject { object.etp }

    let(:fake) { Faker::Lorem.word }
    before { allow(I18n).to receive(:t).and_return(fake) }

    it 'plan_lot will be published at etp' do
      allow(object).to receive(:etp?) { true }
      should eq fake
    end

    it 'plan_lot will be published at newspaper' do
      allow(object).to receive(:etp?) { false }
      should eq nil
    end
  end

  describe '#tender_type_name_with_pkfo' do
    subject { object.tender_type_name_with_pkfo }

    context 'lot for pkfo' do
      let(:plan_lot) { build(:plan_lot, :pastselection) }

      it { should eq "#{plan_lot.tender_type_name} #{plan_lot.preselection.tender_type_name}" }
    end

    context 'simple lot' do
      it { should eq plan_lot.tender_type_name }
    end
  end

  describe '#tender_type_fullname_with_pkfo' do
    subject { object.tender_type_fullname_with_pkfo }

    context 'lot for pkfo' do
      let(:plan_lot) { build(:plan_lot, :pastselection) }

      let(:translation) { Faker::Lorem.word }

      before { allow(I18n).to receive(:t) { translation } }

      it { should eq "#{plan_lot.tender_type_fullname} #{translation}" }
    end

    context 'simple lot' do
      it { should eq plan_lot.tender_type_fullname }
    end
  end

  describe '#announce_attributes' do
    subject { object.announce_attributes }

    context 'plan_lot has no protocols' do
      before { allow(object).to receive(:last_protocol_version) { nil } }

      it { should eq(title: nil) }
    end

    context 'plan_lot has protocol and' do
      let(:plan_lot) { create(:plan_lot, :agreement) }

      let(:fake) { double(PlanLot, announce_date: 2.days.ago) }

      before do
        allow(object).to receive(:last_protocol_version) { fake }
        allow(object).to receive(:last_agree_version) { fake }
      end

      context 'was cancelled' do
        before do
          allow(object).to receive(:last_agree_version) { double }
        end

        it { should eq(title: nil) }
      end

      context 'was declared' do
        let(:status) { Faker::Lorem.word }
        let(:style) { Faker::Lorem.word }
        before do
          allow(object).to receive(:declared?) { true }
          allow(object).to receive(:last_public_lot) {
            double(Lot, status_stylename_html: style, status_fullname: status)
          }
        end

        it { should eq(style: style, title: status) }
      end

      context 'was not declared and' do
        before { allow(object).to receive(:declared?) { false } }

        context 'date was not expired' do
          let(:fake) { double(PlanLot, announce_date: 2.days.from_now) }

          it { should eq(title: nil) }
        end

        context 'date was expired' do
          let(:title) { Faker::Lorem.word }

          before do
            allow(object).to receive_message_chain(:non_executions, :present?) { present }
            allow(I18n).to receive(:t) { title }
          end

          context 'reasons for non executions are present' do
            let(:present) { true }

            it { should eq(class: 'undeclared-with-comment', title: title) }
          end

          context 'reasons for non executions are not present' do
            let(:present) { false }

            it { should eq(class: 'undeclared-without-comment', title: title) }
          end
        end
      end

    end
  end

  describe '#deadline_charge_date' do
    it "Return correct deadline charge date" do
      expect(plan_lot.decorate.deadline_charge_date).to eq(plan_lot.announce_date - 24)
    end
  end

  describe '#rgs?' do
    it "Return true if organizer RGS" do
      plan_lot.department.id = Constants::Departments::RGS
      expect(plan_lot.decorate.rgs?).to eq(true)
    end

    it "Return false if organizer not RGS" do
      plan_lot.department.id = Constants::Departments::RAO
      expect(plan_lot.decorate.rgs?).to eq(false)
    end
  end
end
