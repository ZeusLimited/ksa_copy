# frozen_string_literal: true

require 'spec_helper'

module PlanLots
  RSpec.describe EisNumUpdate do
    let(:plan_lot) { create(:plan_lot) }
    let(:model) { create(:eis_plan_lot, plan_lot_guid: plan_lot.guid, year: plan_lot.announce_date.year) }

    let(:params) do
      {
        id: id,
        eis_plan_lot: { num: eis_num },
      }
    end

    let(:id) { model.id }
    let(:eis_num) { Faker::Number.number(10) }

    let(:operation_run) { described_class.call(params) }
    let(:result) { operation_run.success? }
    let(:operation) { operation_run }

    describe '#process!' do
      context 'success' do
        it { expect(result).to eq true }
        it { expect(operation["model"].num).to eq eis_num }
      end
    end
  end
end
