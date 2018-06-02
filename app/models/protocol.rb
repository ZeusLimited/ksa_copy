# frozen_string_literal: true

class Protocol < ApplicationRecord
  include Constants
  has_paper_trail

  has_many :plan_lots, validate: false
  has_many :protocol_files
  belongs_to :format, class_name: 'Dictionary', foreign_key: 'format_id'
  belongs_to :commission

  delegate :czk?, :sd?, :name, to: :commission, prefix: true, allow_nil: true
  delegate :name, to: :format, prefix: true

  validates :commission_id, :date_confirm, :format_id, :num, :gkpz_year, presence: true
  validates :num, :location, length: { maximum: 255 }

  accepts_nested_attributes_for :protocol_files, allow_destroy: true

  validate :check_dates_for_merge_protocols, if: :merge_ids
  def check_dates_for_merge_protocols
    min_date = boundary_protocols.start_date
    max_date = boundary_protocols.end_date
    errors.add(:date_confirm, :check_date_lots_form_merge_greater, min_date: min_date) if min_date && date_confirm < min_date
    errors.add(:date_confirm, :check_date_lots_form_merge_less, max_date: max_date) if max_date && date_confirm > max_date
  end

  validate :cancel_only_czk
  def cancel_only_czk
    return unless commission
    errors.add(:base, :cancel_only_czk) if !commission_czk? && any_cancel_reglament_lots?
  end

  validate :must_have_files
  def must_have_files
    return unless commission && (commission_czk? || commission_sd?)
    errors.add(:base, :absent_files) if protocol_files.empty? || protocol_files.all?(&:_destroy)
  end

  after_create :set_other_as_unplan

  def set_other_as_unplan
    return unless plan_lots.exists? && single_sd?

    not_in_lots = PlanLot.select(:guid)
                         .where(['protocol_id = ? or status_id = ?', id, PlanLotStatus::CANCELED])
                         .distinct

    PlanLot.where(gkpz_year: gkpz_year, root_customer_id: plan_lots.first.root_customer_id)
           .where.not(guid: not_in_lots)
           .update_all(state: PlanLot.states[:unplan])
  end

  attr_accessor :protocol_type, :merge_ids

  set_date_columns :date_confirm if oracle_adapter?

  scope :by_year_and_cust_and_ctype, (lambda do |year, cust, ctype|
    joins(:commission)
    .where(gkpz_year: year)
    .where(commissions: { department_id: cust, commission_type_id: ctype })
  end)

  class << self
    def build_for_merge(pids)
      first_protocol = Protocol.find(pids.first)
      protocol = first_protocol.dup
      protocol.protocol_files = ProtocolFile.where(protocol_id: pids).map do |pf|
        pf.deep_clone only: [:tender_file_id, :note]
      end
      protocol.merge_ids = pids
      protocol.protocol_type = first_protocol.sd? ? 'sd' : 'zk'
      protocol
    end

    def find_first_confirm_by_announce_date(guid, begin_date, end_date, announce_date)
      joins(:plan_lots)
        .guid_eq('plan_lots.guid', guid_field(guid))
        .where(plan_lots: { announce_date: announce_date })
        .where(plan_lots: { status_id: Constants::PlanLotStatus::AGREEMENT })
        .where(date_confirm: begin_date..end_date)
        .order(:date_confirm)
        .first
    end
  end

  # example: discuss_plan_lots = [{"id"=>"903370", "status_id"=>"15004", "state"=>"plan", "tender_type_id"=>"10015"}]
  def discuss_plan_lots
    @discuss_plan_lots || []
  end

  def discuss_plan_lots_attributes=(attributes)
    @discuss_plan_lots = attributes.values
  end

  def sd?
    if persisted?
      commission.commission_type_id == CommissionType::SD
    else
      protocol_type == 'sd'
    end
  end

  def save_with_discuss_plan_lots(current_user)
    self.gkpz_year = PlanLot.find(discuss_plan_lots.first['id']).gkpz_year
    return false unless valid?

    all_lot_ids = discuss_plan_lots.map { |l| l['id'].to_i }

    error_lots = all_lot_ids.in_groups_of(ORACLE_MAX_IN_CLAUSE, false).reduce([]) do |results, array|
      results + check_date_lots(array)
    end

    return false if date_erros_exist_for?(error_lots)

    transaction do
      ProtocolPlanLotsTmp.create_unless_exists

      discuss_plan_lots.each do |dpl|
        state = sd? ? true : dpl['state'] == 'plan'
        ProtocolPlanLotsTmp.create(user_id: current_user.id, plan_lot_id: dpl['id'],
                                   status_id: dpl['status_id'], is_plan: state)
      end

      ActiveRecord::Base.exec_procedure("pcg_gkpz.bind_lots_to_protocol(#{id})") if save
      id.present?
    end
  end

  def update_merge_protocols
    fail "merge_ids empty!" if merge_ids.blank?
    ActiveRecord::Base.transaction do
      merge_plan_lots.update_all(protocol_id: id)
      merge_protocols.delete_all
    end
  end

  def merge_plan_lots
    PlanLot.where(protocol_id: merge_ids)
  end

  def merge_protocols
    Protocol.where(id: merge_ids)
  end

  def single_sd?
    protocols = Protocol.by_year_and_cust_and_ctype(gkpz_year, plan_lots.first.root_customer_id, CommissionType::SD)
    sd? && protocols.count == 1 && protocols.first.id == id
  end

  private

  def boundary_protocols
    sql = <<-SQL
      select
        max(previous_protocol_date) as start_date,
        min(next_protocol_date) as end_date
        from plan_lots pl
        inner join protocols p on pl.protocol_id = p.id
        inner join lateral (
        select
        max(case when tp.date_confirm <= p.date_confirm then tp.date_confirm end) as previous_protocol_date,
        min(case when tp.date_confirm >= p.date_confirm then tp.date_confirm end) as next_protocol_date
      from plan_lots tpl
        inner join protocols tp on tpl.protocol_id = tp.id
        where
          tpl.id != pl.id and
          tpl.guid = pl.guid
      ) sub on true
      where p.id in (:merge_ids)
    SQL
    @boundary_protocols ||= Protocol.find_by_sql([sql, { merge_ids: merge_ids }]).first
  end

  def date_erros_exist_for?(error_lots)
    return false if error_lots.empty?
    lots = error_lots.map { |l| "№#{l.full_num}, #{l.max_date_confirm.to_date.to_s(:default)}" }
    errors.add(:date_confirm, :check_date_lots, lots: lots.join('<br />'))
    true
  end

  def any_cancel_reglament_lots?
    discuss_plan_lots.any? do |dpl|
      dpl['status_id'].to_i == PlanLotStatus::CANCELED && dpl['tender_type_id'].to_i != TenderTypes::UNREGULATED
    end
  end

  def check_date_lots(plan_lot_ids)
    sql = <<-SQL
      select pl.id, pl.num_tender, pl.num_lot, cdate.max_date_confirm
      from plan_lots pl
      inner join (
        select distinct
          plm.guid,
          first_value(pm.date_confirm) over (partition by plm.guid order by pm.date_confirm desc) as max_date_confirm
        from plan_lots plm
        inner join protocols pm on plm.protocol_id = pm.id
      ) cdate on pl.guid = cdate.guid
      where pl.id in (:plan_lot_ids) and max_date_confirm >= :date_confirm
    SQL
    PlanLot.find_by_sql [sql, { plan_lot_ids: plan_lot_ids, date_confirm: date_confirm }]
  end
end
