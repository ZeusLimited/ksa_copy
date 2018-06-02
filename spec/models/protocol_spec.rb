require 'spec_helper'

describe Protocol do
  it "::build_for_merge" do
    pl1 = create(:plan_lot)
    pl2 = create(:plan_lot)

    p1 = create(:protocol, plan_lots: [pl1], commission: create(:commission, :level1_kk))
    p2 = create(:protocol, plan_lots: [pl2], commission: create(:commission, :level2_kk))

    p3 = Protocol.build_for_merge([p1.id, p2.id])

    expect(p3).to be_a_new(Protocol)
    expect(p3.merge_ids).to eq([p1.id, p2.id])
    expect(p3.protocol_type).to eq('zk')
  end

  it "#set_other_as_unplan" do
    gkpz_year = 2014
    root_customer = create(:department)

    pl_for_sd = create(:plan_lot, root_customer: root_customer, gkpz_year: gkpz_year)
    pl = create(:plan_lot, root_customer: root_customer, gkpz_year: gkpz_year)

    create(
      :protocol,
      gkpz_year: gkpz_year,
      plan_lots: [pl_for_sd],
      protocol_files: [build(:protocol_file)],
      commission: create(:commission, :sd, department: root_customer)
    )
    pl.reload
    expect(pl.state).to eq('unplan')
  end

  it "#save_with_discuss_plan_lots" do
    # example: discuss_plan_lots = [{"id"=>"903370", "status_id"=>"15004", "state"=>"plan"}]
    pl = create(:plan_lot)
    user = create(:user)

    p = build(
      :protocol,
      commission: create(:commission, :level1_kk),
      discuss_plan_lots_attributes:
        { "0" => { "id" => pl.id, "status_id" => PlanLotStatus::CONFIRM_SD, "state" => "plan" } }
    )

    expect(p.save_with_discuss_plan_lots(user)).to be true
    expect(p).to be_persisted
    expect(p.plan_lots.first.guid).to eq(pl.guid)
  end

  it "#update_merge_protocols" do
    allow_any_instance_of(Protocol).to receive(:date_erros_exist_for?).and_return false

    pl1 = create(:plan_lot)
    pl2 = create(:plan_lot)

    p1 = create(:protocol,
                plan_lots: [pl1],
                protocol_files: [build(:protocol_file)],
                commission: create(:commission, :sd))
    p2 = create(:protocol, plan_lots: [pl2], protocol_files: [build(:protocol_file)])

    p3 = create(:protocol, protocol_files: [build(:protocol_file)], merge_ids: [p1, p2])
    p3.update_merge_protocols

    expect(Protocol.count).to eq(1)
    expect(Protocol.first.plan_lots.to_a).to contain_exactly(pl1, pl2)
  end

  describe '#check_dates_for_merge_protocols' do
    let(:new_protocol_1) { create(:protocol_with_files, date_confirm: Faker::Date.backward(1)) }
    let(:new_protocol_2) { create(:protocol_with_files, date_confirm: Faker::Date.backward(1)) }
    let(:old_protocol_1) { create(:protocol_with_files, date_confirm: Faker::Date.between(5.days.ago, 5.days.ago)) }
    let(:old_protocol_2) { create(:protocol_with_files, date_confirm: Faker::Date.between(5.days.ago, 5.days.ago)) }
    let(:very_old_protocol_1) { create(:protocol_with_files, date_confirm: Faker::Date.between(10.days.ago, 10.days.ago)) }

    let!(:new_plan_lot_1) { create(:plan_lot, protocol: new_protocol_1) }
    let!(:new_plan_lot_2) { create(:plan_lot, protocol: new_protocol_2) }
    let!(:old_plan_lot_1) { create(:plan_lot, guid: new_plan_lot_1.guid, protocol: old_protocol_1) }
    let!(:old_plan_lot_2) { create(:plan_lot, guid: new_plan_lot_2.guid, protocol: old_protocol_2) }
    let!(:very_old_plan_lot_1) { create(:plan_lot, guid: new_plan_lot_1.guid, protocol: very_old_protocol_1) }

    let(:error_message) { /Дата нового протокола должна быть (меньше|больше)/ }

    context 'when merge last protocols' do
      let(:result_protocol) { Protocol.build_for_merge([new_protocol_1.id, new_protocol_2.id]) }

      context 'and protocol data equal current date' do
        it 'should pass' do
          result_protocol.date_confirm = new_protocol_1.date_confirm
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to_not include(error_message)
        end
      end

      context 'and protocol data greater than current date' do
        it 'should pass' do
          result_protocol.date_confirm = new_protocol_1.date_confirm + 1
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to_not include(error_message)
        end
      end

      context 'and protocol data less than current date' do
        it 'should pass' do
          result_protocol.date_confirm = new_protocol_1.date_confirm - 1
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to_not include(error_message)
        end
      end

      context 'and protocol data less than old date' do
        let(:error_message) do
          SpecError.model_message(:protocol, :date_confirm, :check_date_lots_form_merge_greater, min_date: old_protocol_1.date_confirm)
        end

        it 'should fails' do
          result_protocol.date_confirm = old_protocol_1.date_confirm - 1
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to include(error_message)
        end
      end
    end

    context 'when merge old protocols' do
      let(:result_protocol) { Protocol.build_for_merge([old_protocol_1.id, old_protocol_2.id]) }

      context 'and protocol data equal current date' do
        it 'should pass' do
          result_protocol.date_confirm = old_protocol_1.date_confirm
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to_not include(error_message)
        end
      end

      context 'and protocol data greater than current date' do
        it 'should pass' do
          result_protocol.date_confirm = old_protocol_1.date_confirm + 1
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to_not include(error_message)
        end
      end

      context 'and protocol data less than current date' do
        it 'should pass' do
          result_protocol.date_confirm = old_protocol_1.date_confirm - 1
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to_not include(error_message)
        end
      end

      context 'and protocol data less than very old date' do
        let(:error_message) do
          SpecError.model_message(:protocol, :date_confirm, :check_date_lots_form_merge_greater, min_date: very_old_protocol_1.date_confirm)
        end

        it 'should fails' do
          result_protocol.date_confirm = very_old_protocol_1.date_confirm - 1
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to include(error_message)
        end
      end

      context 'and protocol data greater than very new date' do
        let(:error_message) do
          SpecError.model_message(:protocol, :date_confirm, :check_date_lots_form_merge_less, max_date: new_protocol_1.date_confirm)
        end

        it 'should fails' do
          result_protocol.date_confirm = new_protocol_1.date_confirm + 1
          result_protocol.valid?
          expect(result_protocol.errors[:date_confirm]).to include(error_message)
        end
      end
    end
  end
end
