def delete_for_models(models)
  models.each do |model|
    puts "Delete all from table #{model.to_s.pluralize}"
    model.delete_all
  end
end

namespace :my do
  desc "Удалить все лоты и всё с ними связанное"
  task :clear_lots => :environment  do
    models = [SpecificationInvestProject, PlanSpecAmount, PlanSpecification, PlanLot]
    delete_for_models models
  end
end