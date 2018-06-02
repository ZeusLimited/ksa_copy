def calc_parent_id_for_okved
  okved = Okved.where(ref_type: 'OKVED')
  okved.each_with_index do |row, index|
    if row.code.length == 2
      case row.code.to_i
        when 1..2
          a = Okved.where(code: 'РАЗДЕЛ A').first.id
        when 5
          a = Okved.where(code: 'РАЗДЕЛ B').first.id
        when 10..12
          a = Okved.where(code: 'Подраз CA').first.id
        when 13..14
          a = Okved.where(code: 'Подраз CB').first.id
        when 15..16
          a = Okved.where(code: 'Подраз DA').first.id
        when 17..18
          a = Okved.where(code: 'Подраз DB').first.id
        when 19
          a = Okved.where(code: 'Подраз DC').first.id
        when 20
          a = Okved.where(code: 'Подраз DD').first.id
        when 21..22
          a = Okved.where(code: 'Подраз DE').first.id
        when 23
          a = Okved.where(code: 'Подраз DF').first.id
        when 24
          a = Okved.where(code: 'Подраз DG').first.id
        when 25
          a = Okved.where(code: 'Подраз DH').first.id
        when 26
          a = Okved.where(code: 'Подраз DI').first.id
        when 27..28
          a = Okved.where(code: 'Подраз DJ').first.id
        when 29
          a = Okved.where(code: 'Подраз DK').first.id
        when 30..33
          a = Okved.where(code: 'Подраз DL').first.id
        when 34..35
          a = Okved.where(code: 'Подраз DM').first.id
        when 36..37
          a = Okved.where(code: 'Подраз DN').first.id
        when 40..41
          a = Okved.where(code: 'РАЗДЕЛ E').first.id
        when 45
          a = Okved.where(code: 'РАЗДЕЛ F').first.id
        when 50..52
          a = Okved.where(code: 'РАЗДЕЛ G').first.id
        when 55
          a = Okved.where(code: 'РАЗДЕЛ H').first.id
        when 60..64
          a = Okved.where(code: 'РАЗДЕЛ I').first.id
        when 65..67
          a = Okved.where(code: 'РАЗДЕЛ J').first.id
        when 70..74
          a = Okved.where(code: 'РАЗДЕЛ K').first.id
        when 75
          a = Okved.where(code: 'РАЗДЕЛ L').first.id
        when 80
          a = Okved.where(code: 'РАЗДЕЛ M').first.id
        when 85
          a = Okved.where(code: 'РАЗДЕЛ N').first.id
        when 90..93
          a = Okved.where(code: 'РАЗДЕЛ O').first.id
        when 95
          a = Okved.where(code: 'РАЗДЕЛ P').first.id
        when 99
          a = Okved.where(code: 'РАЗДЕЛ Q').first.id
      end

    elsif row.code.length == 4
      a = Okved.where(code: row.code[0,2]).first.id
    elsif row.code.length == 5
      a = Okved.where(code: row.code[0,4]).first.id
    elsif row.code.length == 7
      a = Okved.where(code: row.code[0,5]).first.id
    elsif row.code.length == 8 && row.code.index('РАЗДЕЛ') == nil
      a = Okved.where(code: row.code[0,7]).first.id
    elsif row.code.index('Подраз')
      a = Okved.where(code: 'РАЗДЕЛ '+row.code[-2]).first.id
    else
      a = nil
    end
    row.parent_id = a
    row.save
    row.update_column(:parent_id, a)
  end
end

def load_okved2
  Okved.where(ref_type: 'OKVED2').delete_all

  load_from_csv('./db/csv/okved2.csv', ',') do |r|
    parent_id = Okved.where(ref_type: 'OKVED2').where(code: r[1]).first.try(:id)
    okved = Okved.create(parent_id: parent_id, code: r[0], name: r[2], ref_type: 'OKVED2')
    okved.update_column(:parent_id, parent_id)
  end

  puts "Calc parent_id for okved"
  # calc_parent_id_for_okved
  Okved.where(parent_id: nil).update_all(parent_id: 0)
end

def load_okved
  Okved.where(ref_type: 'OKVED').delete_all

  load_from_csv('./db/csv/okved.csv', ';') do |r|
    # parent_id = Okved.where(ref_type: 'OKVED').where(code: r[1]).first.try(:id)
    Okved.create(code: r[0], name: r[1], ref_type: 'OKVED')
  end

  puts "Calc parent_id for okved"
  calc_parent_id_for_okved
  Okved.where(parent_id: nil).update_all(parent_id: 0)
end

