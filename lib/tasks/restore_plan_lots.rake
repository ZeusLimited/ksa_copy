def get_stored_objects(item_type, object_options)
  PaperTrail::Version.where(item_type: item_type, event: 'destroy')
    .where_object(object_options).order(created_at: :desc)
    .map(&:reify)
end

namespace :plan_lots do
  desc "Восстановление удаленных планлотов"
  task :restore_all_versions, [:num_lots] => [:environment] do |task, args|
    Array(args.num_lots).each do |num|
      num_tender, num_lot = num.split '.'
      get_stored_objects('PlanLot', num_tender: num_tender, num_lot: num_lot, gkpz_year: 2017).each do |pl|
        pl.state ||= :plan

        pl.plan_lot_contractors = get_stored_objects('PlanLotContractor', plan_lot_id: pl.id)

        pl.plan_lots_files = get_stored_objects('PlanLotFile', plan_lot_id: pl.id)

        pl.plan_annual_limits = get_stored_objects('PlanAnnualLimit', plan_lot_id: pl.id)

        get_stored_objects('PlanSpecification', plan_lot_id: pl.id).each do |ps|

          ps.fias_plan_specifications = get_stored_objects('FiasPlanSpecification', plan_specification_id: ps.id)
          ps.plan_spec_amounts = get_stored_objects('PlanSpecAmount', plan_specification_id: ps.id)

          pl.plan_specifications << ps
        end

        ap pl.save(validate: false)

      end
    end
  end
end
