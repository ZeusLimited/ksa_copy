class DropFiasTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :fias_addrs
    drop_table :fias_houses
    drop_table :fias_socrbases
  end

  def down
    create_table "fias_addrs", primary_key: "aoid", force: :cascade, comment: "ФИАС адреса" do |t|
      t.uuid    "aoguid",                  null: false, comment: "ГУИД адресного объекта"
      t.uuid    "parentguid",                           comment: "ИД родительского объекта"
      t.uuid    "previd",                               comment: "ИД предыдущей исторической записи"
      t.uuid    "nextid",                               comment: "ИД последующей исторической записи"
      t.integer "aolevel",                 null: false, comment: "Уровень адресного объекта"
      t.string  "formalname", limit: 120,  null: false, comment: "Формализованное наименование"
      t.string  "offname",    limit: 120,               comment: "Официальное наименование"
      t.string  "shortname",  limit: 10,   null: false, comment: "Краткое наименование типа объекта"
      t.string  "okato",      limit: 11,                comment: "ОКАТО"
      t.string  "oktmo",      limit: 11,                comment: "ОКТМО"
      t.string  "regioncode", limit: 2,    null: false, comment: "Код региона"
      t.string  "postalcode", limit: 6,                 comment: "Почтовый индекс"
      t.boolean "actstatus",               null: false, comment: "Статус актуальности"
      t.string  "fullname",   limit: 1000,              comment: "Полный адрес (со всеми уровнями)"
    end

    create_table "fias_houses", primary_key: "houseid", force: :cascade, comment: "ФИАС дома" do |t|
      t.uuid   "aoguid",                null: false, comment: "ГУИД родительского объекта (улицы, города и т.п.)"
      t.uuid   "houseguid",             null: false, comment: "ГУИД дома"
      t.string "buildnum",   limit: 10,              comment: "Номер корпуса"
      t.string "housenum",   limit: 20,              comment: "Номер дома"
      t.string "okato",      limit: 11,              comment: "ОКАТО"
      t.string "oktmo",      limit: 11,              comment: "ОКТМО"
      t.string "postalcode", limit: 6,               comment: "Почтовый индекс"
      t.string "strucnum",   limit: 10,              comment: "Номер строения"
      t.date   "enddate",               null: false, comment: "Окончание действия записи"
    end

    add_index "fias_houses", ["aoguid"], name: "index_fias_houses_on_aoguid", using: :btree

    create_table "fias_socrbases", id: false, force: :cascade, comment: "Типы адресных объектов" do |t|
      t.string  "scname",   limit: 10,              comment: "Краткое наименоание"
      t.string  "socrname", limit: 50, null: false, comment: "Полное наименование"
      t.boolean "is_first",            null: false, comment: "Должно идити перед наименованием объекта?"
      t.boolean "need_dot",            null: false, comment: "Нужна ли точка после наименования?"
    end

    add_index "offers", ["bidder_id", "lot_id", "num", "version"], name: "i_offers_bidder_lot_num_vers", unique: true, using: :btree
  end
end
