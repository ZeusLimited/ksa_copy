class ProtocolFilter
  include ActiveModel::Model

  attr_accessor(
    :year,
    :department,
    :commission_type
  )

  SELECT_PHRASE = <<-SQL
    protocols.*,
    commissions.name as name_commission,
    dictionaries.name as name_format,
    (select
      count(*)
     from plan_lots
     where plan_lots.protocol_id = protocols.id
       and plan_lots.protocol_id is not null) as plan_lots_count
  SQL

  def search
    rows = Protocol.order(:date_confirm).joins(:commission).joins(:format)
    rows = rows.where(gkpz_year: year)
    rows = rows.where(commissions: { department_id: department })
    rows = rows.where(commissions: { commission_type_id: commission_type }) if commission_type.present?
    rows = rows.select(SELECT_PHRASE)
    rows
  end
end
