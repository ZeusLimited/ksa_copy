module ProtocolsHelper
  def change_plan_lot_values(plan_lot, protocol)
    # example: protocol.discuss_plan_lots = [
    #   {"id"=>"903370", "status_id"=>"15004", "state"=>"plan", "tender_type_id"=>"10015"}
    # ]
    if action_name == 'new'
      plan_lot.status_id = protocol.sd? ? Constants::PlanLotStatus::CONFIRM_SD : Constants::PlanLotStatus::AGREEMENT
    else
      val = protocol.discuss_plan_lots.find { |p| p['id'] == plan_lot.id.to_s }
      if val
        plan_lot.status_id = val['status_id'].to_i
        plan_lot.state = val['state']
      end
    end

    plan_lot
  end
end
