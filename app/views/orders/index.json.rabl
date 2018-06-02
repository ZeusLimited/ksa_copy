collection @orders
attributes *Order.column_names, :received_from_fio_full
node(:plan_lots_size) { |order| order.plan_lots.size }
