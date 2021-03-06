class RebidProtocolDecorator < Draper::Decorator
  include Constants
  delegate_all

  SCOPE_LOCAL = [:rebid_protocol_decorator]

  def members(html = false)
    result = RuPropisju.propisju(present_members.size, 1).mb_chars.capitalize.to_s
    result = h.abbr(result, present_members.map(&:user_fio_full).join("\n")) if html
    [result, I18n.t(:member, count: present_members.size), commission_name_r].join(' ')
  end

  def covers
    @covers ||= offers.rebid
  end

  def present_members
    @present_members ||= rebid_protocol_present_members
  end

  def rebid_time_with_zone
    h.local_time_with_msk(rebid_date, tender_local_time_zone)
  end

  def count_string(type, method, gender = 1, locale = :ru)
    size = self.send(method).size
    h.count_with_description size, gender, type, locale
  end

  def reasons_for_execute_tender
    @reasons ||= gkpz_lots.map do |plan_lot|
      if plan_lot.status_id == PlanLotStatus::CONFIRM_SD
        I18n.t('gkpz', scope: SCOPE_LOCAL, ownership: plan_lot.root_customer_ownership_shortname,
                       name: plan_lot.root_customer_name, year: plan_lot.gkpz_year)
      else
        I18n.t('czk', scope: SCOPE_LOCAL, ownership: plan_lot.root_customer_ownership_shortname,
                      name: plan_lot.root_customer_name, date: plan_lot.protocol_date_confirm,
                      num: plan_lot.protocol_num)
      end
    end.uniq
  end

  def plan_cost
    lots.map do |lot|
      pl = gkpz_lots.select { |plan_lot| plan_lot.guid == lot.plan_lot_guid }.first
      { num: lot.num, cost: pl.all_cost } if pl
    end.compact
  end

  def public_cost
    lots.map do |lot|
      pl = gkpz_lots.select { |plan_lot| plan_lot.guid == lot.plan_lot_guid }.first
      { num: lot.num, cost: lot.specs_cost } if pl.nil? || lot.specs_cost != pl.all_cost
    end.compact
  end

  private

  def gkpz_lots
    @gkpz_lots ||= PlanLot
                    .gkpz(rebid_date, CommissionType::MAIN_GROUP)
                    .where(guid: plan_lots.select(:guid).except(:order))
  end
end
