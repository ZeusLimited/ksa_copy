namespace :delete_protocol do
  desc "Удаляет протокол СД + связанную с ним и предыдущую версию (перепривязывает лоты)"
  task :sd_with_prev_version, [:protocol_id] => :environment do |task, args|
    protocol = Protocol.find(args.protocol_id.to_i)

    puts protocol.to_yaml

    unless protocol.commission.commission_type_id == Constants::CommissionType::SD
      puts "Это не протокол СД"
      return
    end

    file = File.open('./tmp/result.txt', 'w')

    executed_lots = []
    rebind_lots = []
    all_deleted_hex = []
    sd_del_lots = []
    pre_sd_del_lots = []

    protocol.plan_lots.each do |plan_lot|
      if plan_lot.execute?
        executed_lots << plan_lot.id
        begin
          rebind_lots << remake_bind(plan_lot)
        rescue => e
          file.puts(e)
          next
        end
      end

      guid_hex = plan_lot.guid_hex
      sd_version = plan_lot
      pre_sd_version = next_version(plan_lot, Constants::PlanLotStatus::PRE_CONFIRM_SD)

      all_deleted_hex << guid_hex
      sd_del_lots << sd_version.id
      pre_sd_del_lots << pre_sd_version.id

      sd_version.destroy
      pre_sd_version.destroy if pre_sd_version
      PlanLot.reindex_versions(guid_hex)
    end

    print_lots = lambda { |var_name, mas| "#{var_name} (#{mas.size}): #{mas.inspect}\n\n" }

    file.puts Time.now
    file.puts print_lots.call('executed_lots', executed_lots)
    file.puts print_lots.call('rebind_lots', rebind_lots)
    file.puts print_lots.call('all_deleted_hex', all_deleted_hex)
    file.puts print_lots.call('sd_del_lots', sd_del_lots)
    file.puts print_lots.call('pre_sd_del_lots', pre_sd_del_lots)
    file.close
  end

  def remake_bind(plan_lot)
    agree_version = next_version(plan_lot, Constants::PlanLotStatus::AGREEMENT)

    fail "not found agree version for plan_lot_id: #{plan_lot.id}" unless agree_version
    fail "agree_version already execute for plan_lot_id: #{plan_lot.id}" if agree_version.execute?
    if plan_lot.plan_specifications.count > 1 || agree_version.plan_specifications.count > 1
      fail "two spec for plan_lot_id: #{plan_lot.id}"
    end

    plan_lot.lots.each { |lot| lot.update_bind(agree_version) }
    agree_version.id
  end

  def next_version(plan_lot, status)
    plan_lot.all_versions.where(status_id: status).first
  end
end
