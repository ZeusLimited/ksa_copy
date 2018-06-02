module OrdersCheck
  extend ActiveSupport::Concern

  def check_lots_for_orders(array_lots)
    array_lots = array_lots.map(&:plan_lot) if array_lots.all? { |l| l.is_a? Lot }
    return if array_lots.all?(&:customer_is_organizer?)

    fail CanCan::AccessDenied, t('check_selected_plan_lots.there_is_no_order') \
         unless array_lots.all? { |pl| pl.customer_is_organizer? || pl.last_valid_order }
    fail CanCan::AccessDenied, t('check_selected_plan_lots.orders_not_approved') unless array_lots.all?(&:confirmed_order?)
    fail CanCan::AccessDenied, t('check_selected_plan_lots.orders_were_published') unless array_lots.all?(&:order_not_published?)
  end
end
