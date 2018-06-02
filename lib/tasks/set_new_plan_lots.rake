namespace :plan_lots do
  desc 'Создание новых лотов с измененными параметрами'
  task set_new_versions: :environment do
    lots = "33.1 34.1 43.1 49.1 53.1 54.1 55.1 56.1 57.1 58.1 60.1 61.1 64.1 69.1 81.1 86.1 98.1 99.1 100.1 101.1 102.1 105.1 105.2 105.3 107.1 108.1 108.2 108.3 115.1 116.1 118.1 120.1 122.1 125.1 129.1 144.1 148.1 152.1 157.1 168.1 172.1 173.1 174.1 175.1 176.1 178.1 180.1 193.1 194.1 204.1 208.1 209.1 210.1 211.1 211.2 211.3 211.4 211.5 211.6 215.1 216.1 219.1 221.1 222.1 223.1 250.1 251.1 252.1"
    PlanLot.transaction do
      PlanLot.actuals.where(gkpz_year: 2016).where(root_customer_id: 2).by_numbers(lots).each do |plan_lot|
        puts "#{plan_lot.num_tender}.#{plan_lot.num_lot}"
        new_plan_lot = plan_lot.deep_clone(
          include: [{ plan_specifications: [:plan_spec_amounts, :fias_plan_specifications]},
          :plan_lot_contractors,
          :plan_lots_files,
          :plan_annual_limits])
        new_plan_lot.status_id = Constants::PlanLotStatus::NEW
        new_plan_lot.department_id = 1000059
        new_plan_lot.commission_id = new_plan_lot.unregulated? ? nil : 749
        new_plan_lot.protocol_id = nil
        new_plan_lot.save
      end
    end
  end
end
