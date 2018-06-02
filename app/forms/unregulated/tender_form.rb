module Unregulated
  class TenderForm < ActiveType::Record[Tender]
    include Constants

    # remove after merge our pull request gem active_type
    attribute :fix_bug_attribute

    validate :winner_for_each_lot
    def winner_for_each_lot
      lots.each do |lot|
        offer_statuses = bidders.map { |b| b.offers.find { |o| o.lot == lot }.try(:status_id) }
        errors.add(:base, :winner_for_each_lot, lot_num: lot.num) unless offer_statuses.count(OfferStatuses::WIN) == 1
      end
    end

    validate :bidders_count
    def bidders_count
      errors.add(:base, :bidders_zero) if bidders.size.zero?
    end

    validate :bidder_offers_count
    def bidder_offers_count
      bidders.each do |bidder|
        errors.add(:base, :bidder_offers_zero) if bidder.offers.size.zero?
      end
    end

    def self.build_from_plan_selected(current_user)
      array_lots = current_user.plan_lots.order('num_tender, num_lot').to_a

      tender = TenderForm.new(user: current_user)
      first_lot = array_lots.first
      tender.tender_type_id = TenderTypes::UNREGULATED
      tender.etp_address_id = EtpAddress::NOT_ETP
      tender.department_id = first_lot.department_id
      tender.name = first_lot.lot_name
      tender.num = first_lot.num_tender

      array_lots.each_with_index { |plan_lot, index| tender.lots << plan_lot.to_lot(index + 1) }
      tender.bidders.build
      tender
    end

    def update_other_attributes
      self.bid_date = announce_date
      self.tender_type_id = TenderTypes::UNREGULATED
      self.etp_address_id = EtpAddress::NOT_ETP

      update_open_protocol
      wp = update_winner_protocol

      update_lots_from_plan_lots(wp) if new_record?
      update_lots

      update_bidders_and_offers
    end

    private

    def update_open_protocol
      op = open_protocol || build_open_protocol
      op.num = 'б/н'
      op.sign_date = announce_date
      op.open_date = announce_date
      op
    end

    def update_winner_protocol
      wp = winner_protocols[0] || winner_protocols.build
      wp.num = 'б/н'
      wp.confirm_date = announce_date
      wp
    end

    def update_lots_from_plan_lots(wp)
      lots.each do |lot|
        wpl = wp.winner_protocol_lots.build
        wpl.lot = lot
        wpl.lot.tender = self
        wpl.solution_type_id = WinnerProtocolSolutionTypes::WINNER

        pl = PlanLot.find(lot.plan_lot_id)
        except_lot_attributes = %w(num non_public_reason note)
        lot.attributes = pl.to_lot(lot.num, false).attributes.except(*except_lot_attributes)

        pl.plan_specifications.each { |ps| lot.specifications << ps.to_specification(false) }
      end
    end

    def update_lots
      lots.each do |lot|
        lot.registred_bidders_count = bidders.size { |b| b.offers.find { |o| o.lot == lot } }
      end
    end

    def update_bidders_and_offers
      bidders.each do |bidder|
        bidder.offers.each do |offer|
          offer.lot = lots.find { |l| l.plan_lot_id.to_i == offer.plan_lot_id.to_i } if offer.lot_id.nil?

          offer.num = 0 # основная
          offer.version = 0
          offer.type_id = CoverLabels::REQUEST

          update_offer_specifications(offer)
        end
      end
    end

    def update_offer_specifications(offer)
      offer.offer_specifications.each do |os|
        offer.contract.lot = offer.lot if offer.contract
        if os.specification_id.nil?
          os.specification = offer.lot.specifications.find do |s|
            s.plan_specification_id.to_i == os.plan_specification_id.to_i
          end
        end
        os.specification.financing_id = os.financing_id

        os.cost = os.final_cost
        os.cost_nds = os.final_cost_nds

        next unless offer.win?

        cs = os.specification.contract_specification || os.specification.build_contract_specification

        cs.contract = offer.contract if cs.contract_id.nil?
        cs.contract.lot = offer.lot if cs.contract.lot_id.nil?

        cs.cost = os.final_cost
        cs.cost_nds = os.final_cost_nds

        update_contract_amount(offer.lot, cs)
      end
    end

    def update_contract_amount(lot, cs)
      ca = cs.contract_amounts[0] || cs.contract_amounts.build

      ca.year = lot.gkpz_year
      ca.amount_finance = cs.cost
      ca.amount_finance_nds = cs.cost_nds
      ca
    end
  end
end
