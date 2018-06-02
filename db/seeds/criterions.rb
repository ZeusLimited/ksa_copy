def create_criterion_from_old(parent_id, type, level = '')
  puts "load criterions for parent_id: #{parent_id}"
  sql = "SELECT * FROM criteria@ksazd_old WHERE parent_id = #{parent_id}"
  User.connection.select_all(sql).each_with_index do |row, i|
    num = "#{level}#{i + 1}."
    Criterion.create(name: row["name"], type_criterion: type, list_num: num)
    create_criterion_from_old(row["id"], type, num)
  end
end

Criterion.delete_all
puts "load draft criterions"
create_criterion_from_old(1, "Draft")
puts "reorder draft criterions"
Criterion.reorder(Criterion.drafts)
puts "load evalution criterions"
create_criterion_from_old(2, "Evalution")
puts "reorder draft evalution"
Criterion.reorder(Criterion.evalutions)
