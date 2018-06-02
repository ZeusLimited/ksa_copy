require 'spec_helper'

RSpec.describe Reports::Gkpz::GkpzOosCommon do
  let(:options) do
    {
      gkpz_year: Time.now.year,
      date_gkpz_on_state: Date.new(Time.now.year, 12, 31)
    }
  end

  subject { Reports::Gkpz::GkpzOosCommon }

  let(:gkpz_oos_common) { Reports::Gkpz::GkpzOosCommon.new(options) }

  describe '#default_params' do
    it 'return correct default_params' do
      expected_result = {
          begin_date: Date.new(Time.now.year, 1, 1),
          end_date: Date.new(Time.now.year, 12, 31),
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year,
          for_order1352: false
      }.with_indifferent_access
      expect(gkpz_oos_common.default_params).to eq(expected_result)
    end
  end

  describe '.generalize_okato' do
    it 'return correct generalized okato code' do
      expect(Reports::Gkpz::GkpzOosCommon.generalize_okato('12345678987')).to eq('12000000000')
    end
  end

  describe '.change_reason' do
    context 'when plan lot change announce_date, tender_type or delivery_date between first and last agreed versions' do
      it 'return 1' do
        allow(subject).to receive(:lot_change).and_return(1)
        allow(subject).to receive(:cost_difference).and_return(0)
        expect(subject.change_reason({})).to eq(1)
      end
    end

    context 'when lot has unplaned state' do
      it 'return 1' do
        allow(subject).to receive(:lot_change).and_return(1)
        allow(subject).to receive(:cost_difference).and_return(0)
        expect(subject.change_reason({})).to eq(1)
      end
    end

    context 'when plan lot has cost difference more then 10% between first and last agreed versions' do
      it 'return 2' do
        allow(subject).to receive(:lot_change).and_return(0)
        allow(subject).to receive(:cost_difference).and_return(2)
        expect(subject.change_reason({})).to eq(2)
      end
    end

    context 'when both conditions change' do
      it 'return 3' do
        allow(subject).to receive(:lot_change).and_return(1)
        allow(subject).to receive(:cost_difference).and_return(2)
        expect(subject.change_reason({})).to eq(3)
      end
    end

    context 'when nothing changes' do
      it 'return 0' do
        allow(subject).to receive(:lot_change).and_return(0)
        allow(subject).to receive(:cost_difference).and_return(0)
        expect(subject.change_reason({})).to eq(0)
      end
    end
  end

  describe '.lot_change' do
    let(:args) do
      current_date = Date.new
      {
        'first_announce_date' => current_date,
        'second_announce_date' => current_date,
        'first_tender_type' => 1,
        'second_tender_type' => 1,
        'first_delivery_date' => current_date,
        'second_delivery_date' => current_date,
        'gkpz_first_state' => 1
      }
    end
    context 'when tender type change' do
      it 'return 1' do
        expect(subject.lot_change(args.merge('second_announce_date' => Date.new + 10.days))).to eq(1)
      end
    end

    context 'when announce date change' do
      it 'return 1' do
        expect(subject.lot_change(args.merge('second_tender_type' => 2))).to eq(1)
      end
    end

    context 'when plan lot state unplanned' do
      it 'return 1' do
        expect(subject.lot_change(args.merge('gkpz_first_state' => 0))).to eq(1)
      end
    end

    context 'when delivery date change' do
      it 'return 1' do
        expect(subject.lot_change(args.merge('second_delivery_date' => Date.new + 10.days))).to eq(1)
      end
    end

    context 'when nothing are change' do
      it 'return 0' do
        expect(subject.lot_change(args)).to eq(0)
      end
    end
  end

  describe '.cost_difference' do
    let(:args) do
      {
        'gkpz_first_cost' => 100,
        'gkpz_last_cost' => 120
      }
    end
    context 'when cost difference more then 10%' do
      it 'return 2' do
        expect(subject.cost_difference(args)).to eq(2)
      end
    end

    context 'when cost difference less or equal 10%' do
      it 'return 0' do
        expect(subject.cost_difference(args.merge('gkpz_last_cost' => 105))).to eq(0)
      end
    end
  end

  describe '#etp_columns' do
    context 'when oos_etp equal 12002' do
      it 'return COLUMNS_ETP_12002' do
        gkpz_oos_common.oos_etp = 12002
        expect(gkpz_oos_common.etp_columns).to eq(Reports::Gkpz::GkpzOosCommon::COLUMNS_ETP_12002)
      end
    end
    context 'when oos_etp equal 12004' do
      it 'return COLUMNS_ETP_12004' do
        gkpz_oos_common.oos_etp = 12004
        expect(gkpz_oos_common.etp_columns).to eq(Reports::Gkpz::GkpzOosCommon::COLUMNS_ETP_12004)
      end
    end
  end

  describe '.eetp_status' do
    let(:row) do
      {
        'status' => 'P'
      }
    end
    it 'return orginal status when nothing changes' do
      allow(subject).to receive(:change_reason).and_return(0)
      expect(subject.eetp_status(row)).to eq('P')
    end
    it 'return change_status if there is changes' do
      allow(subject).to receive(:change_reason).and_return(1)
      expect(subject.eetp_status(row)).to eq('C')
    end
    it 'return original status when plan is cancalled' do
      allow(subject).to receive(:change_reason).and_return(1)
      row['status'] = 'A'
      expect(subject.eetp_status(row)).to eq('A')
    end
  end

end
