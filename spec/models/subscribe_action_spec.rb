require 'spec_helper'

describe SubscribeAction do

  let(:subscribe_action) { build(:subscribe_action) }

  describe '#plan_protocol_with?' do
    shared_examples 'plan_protocol_with?' do |pl_status, factory_trait|
      it "return true if protocol exist and status #{pl_status}" do
        create(:plan_lot, factory_trait, created_at: Time.now + 1.minute, guid: sa.plan_lot.guid, protocol: create(:protocol, :level1_kk))
        expect(sa.send(:plan_protocol_with?, pl_status)).to eq(true)
      end
      it 'return false if protocol not exist' do
        create(:plan_lot, created_at: Time.now + 1.minute, guid: sa.plan_lot.guid)
        expect(sa.send(:plan_protocol_with?, pl_status)).to eq(false)
      end
      it "return false if protocol status not #{pl_status}" do
        create(:plan_lot, :new, created_at: Time.now + 1.minute, guid: sa.plan_lot.guid, protocol: create(:protocol, :level1_kk))
        expect(sa.send(:plan_protocol_with?, pl_status)).to eq(false)
      end
    end

    let(:sa) { create(:subscribe_action_with_subscription) }

    context 'when there is no plan_lot' do
      it 'return nil' do
        allow(subscribe_action).to receive_message_chain(:subscribe, :plan_lot_exists?).and_return(false)
        expect(subscribe_action.send(:plan_protocol_with?, PlanLotStatus::AGREEMENT)).to be_nil
      end
    end

    context 'with PlanLotStatus::AGREEMENT' do
      it_behaves_like 'plan_protocol_with?', PlanLotStatus::AGREEMENT, :agreement
    end

    context 'with PlanLotStatus::CANCELED' do
      it_behaves_like 'plan_protocol_with?', PlanLotStatus::CANCELED, :canceled
    end

    context 'with PlanLotStatus::CONFIRM_SD' do
      it_behaves_like 'plan_protocol_with?', PlanLotStatus::CONFIRM_SD, :confirm_sd
    end

    context 'with PlanLotStatus::EXCLUDED_SD' do
      it_behaves_like 'plan_protocol_with?', PlanLotStatus::EXCLUDED_SD, :excluded_sd
    end
  end

  describe 'occur?' do
    shared_examples 'occur?' do |action, method, option = nil|
      it "call #{method} when action_id is #{action}" do
        sa = build(:subscribe_action, action_id: action)
        expect(sa).to receive(method).with(option || no_args)
        sa.send(:occur?)
      end
    end

    it_behaves_like 'occur?', SubscribeActions::CONFIRM, :plan_protocol_with?, PlanLotStatus::AGREEMENT
    it_behaves_like 'occur?', SubscribeActions::CANCEL_PLAN, :plan_protocol_with?, PlanLotStatus::CANCELED
    it_behaves_like 'occur?', SubscribeActions::CONFIRM_SD, :plan_protocol_with?, PlanLotStatus::CONFIRM_SD
    it_behaves_like 'occur?', SubscribeActions::EXCLUDED_SD, :plan_protocol_with?, PlanLotStatus::EXCLUDED_SD
    it_behaves_like 'occur?', SubscribeActions::PUBLIC, :public?
    it_behaves_like 'occur?', SubscribeActions::OPEN, :open?
    it_behaves_like 'occur?', SubscribeActions::REVIEW, :review?, LotStatus::REVIEW
    it_behaves_like 'occur?', SubscribeActions::REVIEW_CONFIRM, :review?, LotStatus::REVIEW_CONFIRM
    it_behaves_like 'occur?', SubscribeActions::REOPEN, :reopen?
    it_behaves_like 'occur?', SubscribeActions::WINNER, :winner_protocol?, LotStatus::SW
    it_behaves_like 'occur?', SubscribeActions::WINNER_CONFIRM, :winner_protocol?, LotStatus::SW_CONFIRM
    it_behaves_like 'occur?', SubscribeActions::RESULT, :result_protocol?
    it_behaves_like 'occur?', SubscribeActions::CONTRACT, :complete?, LotStatus::CONTRACT
    it_behaves_like 'occur?', SubscribeActions::FAIL, :complete?, LotStatus::FAIL
    it_behaves_like 'occur?', SubscribeActions::CANCEL, :complete?, LotStatus::CANCEL
    it_behaves_like 'occur?', SubscribeWarnings::PUBLIC, :warning_public?
    it_behaves_like 'occur?', SubscribeWarnings::OPEN, :warning_open?
    it_behaves_like 'occur?', SubscribeWarnings::SUMMARIZE, :warning_summarized?
    it 'return true when SubscribeActions::DELETE' do
      sa = build(:subscribe_action_with_subscription, :delete)
      expect(sa.send(:occur?)).to be_truthy
    end
    it 'return false when nothing match to action_id' do
      sa = build(:subscribe_action)
      expect(sa.send(:occur?)).to be_falsey
    end
  end

  describe '#warning_summarized?' do
    context 'when days_to_summary equals days_before' do
      it 'return true' do
        allow(subscribe_action).to receive(:days_to_summary).and_return(3)
        allow(subscribe_action).to receive(:days_before).and_return(3)
        expect(subscribe_action.send(:warning_summarized?)).to be_truthy
      end
    end

    context 'when days_to_summary falls within period' do
      it 'return true' do
        allow(subscribe_action).to receive(:days_to_summary).and_return(2)
        allow(subscribe_action).to receive(:days_before).and_return(3)
        expect(subscribe_action.send(:warning_summarized?)).to be_truthy
      end
    end

    context 'when days_to_summary does not falls within period' do
      it 'return false' do
        allow(subscribe_action).to receive(:days_to_summary).and_return(2)
        allow(subscribe_action).to receive(:days_before).and_return(1)
        expect(subscribe_action.send(:warning_summarized?)).to be_falsey
      end
    end
  end

  describe '#days_to' do
    context 'when action_id SubscribeWarnings::PUBLIC' do
      it 'call days_to_public' do
        sa = build(:subscribe_action, :public_warning)
        expect(sa).to receive(:days_to_public)
        sa.send(:days_to)
      end
    end
    context 'when action_id SubscribeWarnings::OPEN' do
      it 'call days_to_open' do
        sa = build(:subscribe_action, :open_warning)
        expect(sa).to receive(:days_to_open)
        sa.send(:days_to)
      end
    end
    context 'when action_id SubscribeWarnings::SUMMARIZE' do
      it 'call days_to_summary' do
        sa = build(:subscribe_action, :summarize)
        expect(sa).to receive(:days_to_summary)
        sa.send(:days_to)
      end
    end
  end

  describe '#days_to_summary' do
    it 'return nil if there is no subscribe_fact_object' do
      allow(subscribe_action).to receive(:subscribe_fact_object).and_return nil
      expect(subscribe_action.send(:days_to_summary)).to be_nil
    end
    it 'return difference between summary_date and current_date' do
      allow(subscribe_action).to receive(:subscribe_fact_object).and_return({ "summary_date" => (Date.current + 3.days).to_s })
      expect(subscribe_action.send(:days_to_summary)).to eq(3)
    end
  end
end
