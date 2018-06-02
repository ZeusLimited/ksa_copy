def load_bp_state
  puts "load bp state"
  BpState.delete_all

  load_from_csv('./db/csv/bp_state.csv',',') do |r|
    b = BpState.new(
      num: r[0],
      name: r[1])
    b.save(validate: false)
    puts " bp state: #{b.id}"
  end
end