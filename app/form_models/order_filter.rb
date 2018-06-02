class OrderFilter
  include ActiveModel::Model
  include Sortable

  attr_accessor :year, :department, :num, :customers, :not_confirmed

  def search
    order = Order.includes(plan_lots: [:department, :root_customer])
                 .references(plan_lots: [:department, :root_customer])
                 .where(plan_lots: { gkpz_year: year })
                 .where(plan_lots: { department: department })
    order = order.where(ApplicationRecord.multi_value_filter("lower(num) like lower('%s')", num)) if num.present?
    order = order.where(plan_lots: { root_customer_id: customers }) if customers.present?
    order = order.where('orders.agreement_date is null') if not_confirmed.present?
    order = order.sort_by { |o| o.send(sort_column) || max_sort_column(order) }
    order = order.reverse if sort_direction_desc?
    order
  end
end
