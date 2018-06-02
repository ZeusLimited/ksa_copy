require 'csv'
require './db/okved_seed'
require './db/okei_seed'
require './db/bp_state_seed'
# require './db/task_status'


def str_count(count, file)
  "insert #{count} rows from file #{file}"
end

def load_from_csv(file, col_sep = ';')
  if block_given?
    lines = 0
    rows = CSV.read(file, col_sep: col_sep, headers: true)
    rows.each do |r|
      begin
        yield(r)
      rescue => e
        puts ''
        puts r.to_yaml
        puts e
        break
      end
      lines += 1
      print "\r" + str_count(lines, file)
    end
    print "\n"
  end
end

# def change_sequence(name, start_with)
#   ActiveRecord::Base.connection.execute "drop sequence #{name}"
#   ActiveRecord::Base.connection.execute "create sequence #{name} minvalue 1 maxvalue 9999999999999999999999999999 start with #{start_with} increment by 1 nocache"
# end

time_begin = Time.now

OkdpReform.delete_all
load_from_csv('./db/csv/okdp-okpd2.csv') do |r|
  OkdpReform.create(old_value: r[0], new_value: r[1])
end

# OkvedReform.delete_all
# load_from_csv('./db/csv/okved-okved2.csv') do |r|
#   OkvedReform.create(old_value: r[0], new_value: r[1])
# end

# Dictionary.delete_all
# load_from_csv('./db/csv/dictionaries.csv') do |r|
#   Dictionary.create(ref_id: r['REF_ID'], ref_type: r['REF_TYPE'], name: r['NAME'], fullname: r['FULLNAME'], position: r['POSITION'], stylename_html: r['STYLENAME_HTML'])
# end

# FiasSocrbase.delete_all
# load_from_csv('./db/csv/fias_socrbases.csv') do |r|
#   FiasSocrbase.create(scname: r[0], socrname: r[1], is_first: r[2], need_dot: r[3])
# end

# Okdp.where(ref_type: 'OKPD2').delete_all
# load_from_csv('./db/csv/okpd2.csv', ',') do |r|
#   parent_id = Okdp.where(ref_type: 'OKPD2').where(code: r['parent_code']).first.try(:id)

#   okdp = Okdp.create(parent_id: parent_id, code: r['code'], name: r['name'], ref_type: 'OKPD2')
#   okdp.update_column(:parent_id, parent_id)
# end

# OkdpEtp.delete_all
# load_from_csv('./db/csv/okdp_etp.csv', ',') { |r| OkdpEtp.create(code: r['code']) }

# OkdpSme.delete_all
# load_from_csv('./db/csv/okpd2_sme.csv', ',') { |r| OkdpSme.create(code: r['code']) }

# load_okved

# load_okved2

# load_okei

# load_users

# load_task_status

# load_bp_state

time_end = Time.now

puts
puts "it's done for #{time_end - time_begin} seconds."
