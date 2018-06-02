module Innovations
  class PlanLotForm < ActiveType::Record[PlanLot]

    attribute :announce_year, default: proc { announce_date.try(:year) }
    attribute :delivery_year_begin, default: proc { plan_specifications[0].delivery_date_begin.try(:year) }
    attribute :delivery_year_end, default: proc { plan_specifications[0].delivery_date_end.try(:year) }

    validate :okveds

    before_validation :set_special_attributes

    def initialize(args = {})
      super(args)
      self.include_ipivp = true
    end

    def self.find(id)
      instance = super(id)
      instance.include_ipivp = true
      instance
    end

    def self.build_project(current_user_id)
      plf = new(user_id: current_user_id)
      plf.plan_specifications.build
      plf
    end

    def announce_interval
      announce_begin..announce_end
    end

    def set_special_attributes
      self.announce_date = Date.new(announce_year.to_i, 1, 1) if announce_year

      ps = plan_specifications[0]
      ps.qty = 1
      ps.num_spec = 1
      ps.name = lot_name
      ps.cost = 0
      ps.cost_nds = 0
      ps.unit_id = Unit.default.id
      ps.delivery_date_begin = Date.new(delivery_year_begin.to_i, 1, 1) if delivery_year_begin
      ps.delivery_date_end = Date.new(delivery_year_end.to_i, 12, 31) if delivery_year_end
    end

    private

    def okveds
      return if announce_date.year >= announce_end
      ps = plan_specifications[0]
      errors['plan_specifications.okdp_id'] << I18n.t('errors.messages.blank') unless ps.okdp_id
      errors['plan_specifications.okved_id'] << I18n.t('errors.messages.blank') unless ps.okved_id
    end

    def announce_begin
      @announce_begin ||= (Date.current + 6.months + 1.year).year
    end

    def announce_end
      @announce_end ||= (Date.current + 6.months + 4.years).year
    end
  end
end
