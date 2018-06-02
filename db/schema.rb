# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180601053522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "orafce"

  create_table "annual_kpis", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.integer "gkpz_year", null: false
    t.integer "year", null: false
    t.integer "month"
    t.decimal "cost", null: false
    t.decimal "cost_nds", null: false
    t.decimal "etp_cost", null: false
    t.decimal "etp_cost_nds", null: false
    t.decimal "auction_cost", null: false
    t.decimal "auction_cost_nds", null: false
    t.decimal "single_source_cost", null: false
    t.decimal "single_source_cost_nds", null: false
    t.decimal "msp_cost", null: false
    t.decimal "msp_cost_nds", null: false
    t.decimal "submsp_cost", null: false
    t.decimal "submsp_cost_nds", null: false
    t.integer "type_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "arm_departments", id: :serial, force: :cascade, comment: "Предприятия в АРМ минэнерго" do |t|
    t.string "arm_id", null: false, comment: "Идентификатор подразделения в арм минэнерго"
    t.string "name", null: false, comment: "Наименование подразделения в арм минэнерго"
    t.integer "department_id", null: false, comment: "Ссылка на справочник подразделений"
  end

  create_table "assignments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.integer "department_id"
  end

  create_table "b2b_classifiers", id: :serial, force: :cascade, comment: "Классификаторы b2b-center" do |t|
    t.integer "classifier_id", comment: "Id классификатора на площадке b2b"
    t.text "name", comment: "Наименование классификатора"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_classifier_id", comment: "Id родительского элемента"
    t.string "ancestry"
    t.index ["ancestry"], name: "index_b2b_classifiers_on_ancestry"
    t.index ["classifier_id"], name: "index_b2b_classifiers_on_classifier_id"
  end

  create_table "bidder_files", id: :serial, force: :cascade, comment: "Документы предложения участников" do |t|
    t.integer "bidder_id", null: false, comment: "Участник"
    t.integer "tender_file_id", null: false, comment: "Файл"
    t.text "note", comment: "Примечания"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bidder_id", "tender_file_id"], name: "i_bidder_files", unique: true
  end

  create_table "bidders", id: :serial, force: :cascade, comment: "Участник" do |t|
    t.integer "tender_id", null: false, comment: "Закупка"
    t.integer "contractor_id", null: false, comment: "Участник"
    t.boolean "is_presence", default: true, comment: "Присутствовал на процедуре проведения закупки"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tender_id", "contractor_id"], name: "i_bidders_tender_contractor", unique: true
  end

  create_table "bp_states", id: :serial, comment: "Справочник бюджетный кодификатор", force: :cascade, comment: "Справочник бюджетный кодификатор" do |t|
    t.string "num", null: false, comment: "Номер бюджетного кодификатора"
    t.string "name", null: false, comment: "Наименование"
  end

  create_table "cart_lots", id: false, force: :cascade, comment: "Выбранные лоты пользователей" do |t|
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.integer "lot_id", null: false, comment: "ИД лота"
  end

  create_table "commission_users", id: :serial, force: :cascade, comment: "Члены комиссий" do |t|
    t.integer "commission_id", comment: "ИД комиссии"
    t.integer "user_id", comment: "ИД пользователя"
    t.integer "status", comment: "ИД статуса в комиссии"
    t.boolean "is_veto", comment: "Есть право вето"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_job", comment: "Должность (для генерации документации)"
  end

  create_table "commissions", id: :serial, force: :cascade, comment: "Комиссии" do |t|
    t.string "name", comment: "Наименование"
    t.integer "department_id", comment: "ИД подразделения"
    t.integer "commission_type_id", comment: "ИД типа комиссии"
    t.boolean "is_actual", comment: "Актуальность записи"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "for_customers", default: false, null: false, comment: "Может проводить закупки для сторонних заказчиков"
  end

  create_table "contacts", id: :serial, force: :cascade, comment: "Контакт" do |t|
    t.string "web", comment: "Интернет адрес"
    t.string "email", comment: "e-mail"
    t.string "phone", comment: "Номер телефона"
    t.string "fax", comment: "Факс"
    t.integer "version", default: 0, null: false, comment: "Версия"
    t.integer "department_id", null: false, comment: "Предприятие/подразделение"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "contact_person", comment: "Контактное лицо для PR-службы МСП"
    t.integer "legal_fias_id", comment: "Юр. адрес ФИАС"
    t.integer "postal_fias_id", comment: "Почтовый адрес ФИАС"
  end

  create_table "content_offers", id: :serial, force: :cascade, comment: "Справочник требований к составу заявок" do |t|
    t.text "name", null: false, comment: "Наименование"
    t.string "num", null: false, comment: "Номер"
    t.integer "position", default: 100, null: false, comment: "Порядок сортировки"
    t.integer "content_offer_type_id", null: false, comment: "Тип требования"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contract_amounts", id: :serial, force: :cascade, comment: "Обязательства по договору" do |t|
    t.integer "contract_specification_id", null: false, comment: "Ссылка на спецификацию договора"
    t.integer "year", null: false, comment: "Год"
    t.decimal "amount_finance", precision: 18, scale: 2, null: false, comment: "финансирование без НДС"
    t.decimal "amount_finance_nds", precision: 18, scale: 2, null: false, comment: "финансирование с НДС"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_specification_id"], name: "i_amounts_contract_spec"
  end

  create_table "contract_files", id: :serial, force: :cascade, comment: "Файлы договоров" do |t|
    t.integer "contract_id", null: false, comment: "ИД договора"
    t.integer "tender_file_id", null: false, comment: "ИД файла"
    t.integer "file_type_id", null: false, comment: "ИД типа документа"
    t.text "note", comment: "Примечание"
    t.index ["contract_id"], name: "i_contract_files_contract"
  end

  create_table "contract_specifications", id: :serial, force: :cascade, comment: "Спецификация договора" do |t|
    t.integer "contract_id", null: false, comment: "Договор"
    t.integer "specification_id", null: false, comment: "Спецификация"
    t.decimal "cost", precision: 18, scale: 2, null: false, comment: "Стоимость договора без НДС"
    t.decimal "cost_nds", precision: 18, scale: 2, null: false, comment: "Стоимость договора с НДС"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id", "specification_id"], name: "i_contract_specification", unique: true
  end

  create_table "contract_terminations", id: :serial, force: :cascade, comment: "Сведения о расторжениях договоров" do |t|
    t.integer "contract_id", null: false, comment: "Договор"
    t.integer "type_id", null: false, comment: "Способ расторжения"
    t.date "cancel_date", null: false, comment: "Дата расторжения"
    t.decimal "unexec_cost", precision: 18, scale: 2, null: false, comment: "Объем неисполненных обязательств"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "iu_contract_termination", unique: true
  end

  create_table "contractor_files", id: :serial, comment: "Файлы контрагентов", force: :cascade, comment: "Файлы контрагентов" do |t|
    t.integer "contractor_id", null: false, comment: "ID контрагента"
    t.integer "tender_file_id", null: false, comment: "ID файла"
    t.integer "file_type_id", null: false, comment: "ID типа файла"
    t.text "note", comment: "Примечания"
    t.index ["contractor_id"], name: "i_contractor_file_contractor"
  end

  create_table "contractors", id: :serial, force: :cascade, comment: "Контрагенты" do |t|
    t.string "name", limit: 500, null: false, comment: "Наименование"
    t.string "fullname", limit: 500, null: false, comment: "Полное наименование"
    t.string "ownership", limit: 100, comment: "Форма собственности"
    t.string "inn", limit: 12, comment: "ИНН"
    t.string "kpp", limit: 9, comment: "КПП"
    t.string "ogrn", limit: 15, comment: "ОГРН"
    t.string "okpo", limit: 10, comment: "ОКПО"
    t.integer "status", default: 0, null: false, comment: "Статус записи(0-новая, 1-активная, 2-старая)"
    t.integer "form", null: false, comment: "Вид контрагента (0-физ. лицо, 1-юр. лицо, 2-иностран.)"
    t.text "legal_addr", comment: "Юридический адрес"
    t.integer "user_id", null: false, comment: "ИД юзера"
    t.integer "prev_id", comment: "Предыдущий ИД (до переименования)"
    t.integer "next_id", comment: "Следующий ИД (после переименования)"
    t.boolean "is_resident", default: true, comment: "Резидент?"
    t.boolean "is_dzo", default: false, comment: "ДЗО?"
    t.boolean "is_sme", comment: "Субъект малого и среднего предпринимательства?"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "jsc_form_id", comment: "Форма акционерного общества"
    t.integer "sme_type_id", comment: "Малое или среднее предпринимательство"
    t.string "oktmo", limit: 11, comment: "Код ОКТМО"
    t.uuid "guid", comment: "Глобальный идентификатор контрагента"
    t.date "reg_date", comment: "Дата регистрации"
    t.integer "ownership_id", comment: "Идентификатор вида собственности"
    t.string "parent_id", comment: "Ссылка на родителя"
    t.index ["parent_id"], name: "index_contractors_on_parent_id"
  end

  create_table "contracts", id: :serial, force: :cascade, comment: "Договоры" do |t|
    t.integer "lot_id", null: false, comment: "Договоры"
    t.string "num", null: false, comment: "Номер договора"
    t.date "confirm_date", null: false, comment: "Дата подписания договора"
    t.date "delivery_date_begin", null: false, comment: "Дата начала поставки"
    t.date "delivery_date_end", null: false, comment: "Дата окончания поставки"
    t.integer "parent_id", comment: "Ссылка на основной договор"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "non_delivery_reason", comment: "Причина невыполнения сроков начала поставки"
    t.integer "type_id", null: false, comment: "Тип договора (Основной / Доп. на уменьшение)"
    t.integer "offer_id", comment: "ИД победившей оферты"
    t.string "reg_number", comment: "Регистрационный номер"
    t.decimal "total_cost", precision: 18, scale: 2, comment: "Общая стоимость договора без НДС"
    t.decimal "total_cost_nds", precision: 18, scale: 2, comment: "Общая стоимость договора с НДС"
    t.index ["lot_id"], name: "i_contracts_lot"
    t.index ["offer_id"], name: "i_contracts_offer"
  end

  create_table "control_plan_lots", id: :serial, force: :cascade, comment: "Лоты на контроле" do |t|
    t.uuid "plan_lot_guid", null: false, comment: "ГУИД лота в планировании"
    t.integer "user_id", null: false, comment: "ИД пользователя, добавившего лот на контроль"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_lot_guid"], name: "i_control_plan_lots_guid", unique: true
    t.index ["user_id"], name: "i_control_plan_lots_user"
  end

  create_table "covers", id: :serial, force: :cascade, comment: "Конверт" do |t|
    t.integer "bidder_id", null: false, comment: "Участник"
    t.datetime "register_time", comment: "Дата и время"
    t.string "register_num", comment: "Регистрационный номер"
    t.integer "type_id", null: false, comment: "Пометка"
    t.string "delegate", comment: "ФИО представителя"
    t.string "provision", comment: "Форма предоставления"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bidder_id"], name: "i_covers_bidder"
  end

  create_table "criterions", id: :serial, force: :cascade, comment: "Критерии отбора/оценки" do |t|
    t.string "type_criterion", null: false, comment: "Тип критерия (отбор/оценка)"
    t.string "list_num", null: false, comment: "Номер в списке"
    t.integer "position", default: 100, null: false, comment: "Позиция сортировки"
    t.text "name", null: false, comment: "Наименование"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "declensions", id: :serial, force: :cascade, comment: "Склонения" do |t|
    t.integer "content_id"
    t.string "content_type"
    t.string "name_r", comment: "Родительный"
    t.string "name_d", comment: "Дательный"
    t.string "name_v", comment: "Винительный"
    t.string "name_t", comment: "Творительный"
    t.string "name_p", comment: "Предложный"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", id: :serial, force: :cascade, comment: "Подразделения" do |t|
    t.integer "parent_dept_id", comment: "ИД родителя"
    t.string "name", comment: "Наименование"
    t.integer "position", comment: "Порядок сортировки"
    t.boolean "is_customer", comment: "Может быть заказчиком?"
    t.boolean "is_organizer", comment: "Может быть организатором?"
    t.integer "etp_id", comment: "Код на ЭТП"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry", comment: "Служебное поле гема ancestry"
    t.string "fullname", comment: "Полное наименование"
    t.decimal "tender_cost_limit", precision: 18, scale: 2, comment: "Доступный лимит с НДС"
    t.string "inn", limit: 10, comment: "ИНН"
    t.string "kpp", limit: 9, comment: "КПП"
    t.string "ownership", limit: 100, comment: "Форма собственности"
    t.string "full_ownership"
    t.integer "ownership_id", comment: "Идентификатор вида собственности"
    t.string "shortname", limit: 25, comment: "Сокращенное наименование"
    t.boolean "is_consumer", comment: "Является потребителем?"
    t.decimal "eis223_limit", precision: 18, scale: 2, comment: "Лимит установленный п. 15 ст. 4 223-ФЗ"
    t.index ["ancestry"], name: "index_departments_on_ancestry"
  end

  create_table "departments_regulation_items", id: false, force: :cascade do |t|
    t.integer "regulation_item_id", null: false
    t.integer "department_id", null: false
    t.index ["department_id"], name: "index_departments_regulation_items_on_department_id"
    t.index ["regulation_item_id"], name: "index_departments_regulation_items_on_regulation_item_id"
  end

  create_table "dests_experts", id: false, force: :cascade, comment: "Связ. таблица: направления оценки предложения и эксперты" do |t|
    t.integer "destination_id", null: false, comment: "направление оценки предложения"
    t.integer "expert_id", null: false, comment: "эксперт"
  end

  create_table "dests_tender_draft_crits", id: false, force: :cascade, comment: "Связ. таблица: направления оценки предложения и отборочные критерии" do |t|
    t.integer "dictionary_id", null: false, comment: "направление оценки предложения"
    t.integer "tender_draft_criterion_id", null: false, comment: "отборочный критерий"
  end

  create_table "dictionaries", primary_key: "ref_id", id: :serial, comment: "ИД", force: :cascade, comment: "Справочники" do |t|
    t.string "ref_type", comment: "Тип справочника"
    t.string "name", comment: "Краткое наименование"
    t.string "fullname", limit: 4000, comment: "Полное наименование"
    t.boolean "is_actual", comment: "Актуальность записи"
    t.integer "position", comment: "Порядок сортировки"
    t.string "stylename_html", comment: "Стиль HTML"
    t.string "stylename_docx", comment: "Стиль DOCX"
    t.string "stylename_xlsx", comment: "Стиль XLSX"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ref_type"], name: "index_dictionaries_on_ref_type"
  end

  create_table "dictionaries_regulation_items", id: false, force: :cascade do |t|
    t.integer "regulation_item_id", null: false
    t.integer "dictionary_id", null: false
    t.index ["dictionary_id"], name: "index_dictionaries_regulation_items_on_dictionary_id"
    t.index ["regulation_item_id"], name: "index_dictionaries_regulation_items_on_regulation_item_id"
  end

  create_table "directions", id: :serial, comment: "Направления деятельности (разделы ГКПЗ)", force: :cascade, comment: "Направления деятельности (разделы ГКПЗ)" do |t|
    t.string "name", null: false, comment: "Наименование"
    t.string "fullname", null: false, comment: "Полное наименование"
    t.integer "type_id", null: false, comment: "Тип направления деятельности"
    t.integer "position", null: false, comment: "Порядок"
    t.string "yaml_key", comment: "Ключ для yaml файлов отчетов"
    t.boolean "is_longterm", default: false, null: false, comment: "Долгосрочный горизонт планирования?"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "doc_takers", id: :serial, force: :cascade, comment: "Лицо получившее конкурсную документацию" do |t|
    t.integer "contractor_id", null: false, comment: "Наименование"
    t.integer "tender_id", null: false, comment: "Закупка"
    t.date "register_date", comment: "Дата регистрации"
    t.string "reason", limit: 1000, comment: "Основание (письмо от ... исх. № ...)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contractor_id", "tender_id"], name: "i_doc_takers_contractor_tender", unique: true
  end

  create_table "draft_opinions", id: :serial, force: :cascade, comment: "Оценка по отборочным критериям" do |t|
    t.integer "criterion_id", null: false, comment: "Критерий"
    t.integer "expert_id", null: false, comment: "Эксперт"
    t.integer "offer_id", null: false, comment: "Оферта"
    t.boolean "vote", comment: "Оценка"
    t.text "description", comment: "Пояснения"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["expert_id"], name: "i_draft_opinions_expert"
    t.index ["offer_id"], name: "i_draft_opinions_offer"
  end

  create_table "effeciency_indicator_types", id: :serial, comment: "Типы контрольных показателей", force: :cascade, comment: "Типы контрольных показателей" do |t|
    t.string "work_name", null: false, comment: "Рабочее название КПЭ"
    t.text "name", null: false, comment: "Полное наименование КПЭ"
    t.float "weight", null: false, comment: "Вес КПЭ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "effeciency_indicators", id: :serial, comment: "Контрольные показатели для расчета КПЭ", force: :cascade, comment: "Контрольные показатели для расчета КПЭ" do |t|
    t.integer "gkpz_year", null: false, comment: "Год ГКПЗ"
    t.string "work_name", null: false, comment: "Рабочее наименование"
    t.text "name", null: false, comment: "Наименование показателя"
    t.float "value", null: false, comment: "Значение показателя"
  end

  create_table "eis_plan_lots", force: :cascade do |t|
    t.uuid "plan_lot_guid"
    t.integer "year"
    t.string "num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["num"], name: "i_eis_plan_lots_num"
    t.index ["plan_lot_guid"], name: "i_eis_plan_lots_guid"
  end

  create_table "experts", id: :serial, force: :cascade, comment: "Эксперты" do |t|
    t.integer "tender_id", null: false, comment: "Закупка"
    t.integer "user_id", null: false, comment: "Эксперт"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tender_id", "user_id"], name: "i_experts_tender_user", unique: true
  end

  create_table "fias", id: :serial, comment: "Адреса ФИАС", force: :cascade, comment: "Адреса ФИАС" do |t|
    t.uuid "aoid", comment: "ФИАС идентификатор адресного объекта"
    t.uuid "houseid", comment: "ФИАС идентификатор дома"
    t.string "name", limit: 1000, comment: "Наименование"
    t.string "regioncode", limit: 2, comment: "Регион"
    t.string "postalcode", limit: 6, comment: "Почтовый индекс"
    t.string "okato", limit: 11, comment: "ОКАТО"
    t.string "oktmo", limit: 11, comment: "ОКТМО"
  end

  create_table "fias_plan_specifications", id: :serial, force: :cascade, comment: "Адреса спецификаций" do |t|
    t.uuid "houseid", comment: "ГУИД дома"
    t.integer "plan_specification_id", null: false, comment: "ИД спецификации"
    t.uuid "addr_aoid", null: false, comment: "ГУИД адреса"
    t.integer "fias_id", comment: "ФИАС"
    t.index ["plan_specification_id"], name: "index_fias_plan_specifications_on_plan_specification_id"
  end

  create_table "fias_specifications", id: :serial, force: :cascade, comment: "Адреса спецификаций" do |t|
    t.uuid "addr_aoid", null: false, comment: "ГУИД адреса"
    t.uuid "houseid", comment: "ГУИД дома"
    t.integer "specification_id", null: false, comment: "ИД спецификации"
    t.integer "fias_id", comment: "ФИАС"
    t.index ["specification_id"], name: "index_fias_specifications_on_specification_id"
  end

  create_table "foreign_tender_types", id: :serial, force: :cascade, comment: "Внешние коды способов закупок" do |t|
    t.integer "tender_type_id", null: false, comment: "Код способа закупки в системе ТОРГ"
    t.boolean "is_etp", comment: "На ЭТП?"
    t.string "foreign_type", null: false, comment: "Внешняя система"
    t.string "foreign_type_code", null: false, comment: "Код способа закупки во внешней системе"
  end

  create_table "foreign_values", id: false, force: :cascade, comment: "Таблица для сопоставления значений справочников с внешними система" do |t|
    t.string "foreign_id", null: false, comment: "Внешний ключ"
    t.string "foreign_system", null: false, comment: "Название системы"
    t.string "inner_id", null: false, comment: "Внутренний ключ"
    t.string "dictionary_name", null: false, comment: "Название справочника"
  end

  create_table "import_lots", id: false, force: :cascade, comment: "Для импорта строк лотов из Excel" do |t|
    t.integer "num", null: false, comment: "Номер строки"
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.string "gkpz_year", comment: "Год ГКПЗ"
    t.string "num_tender", comment: "номер закупки"
    t.string "num_lot", comment: "номер лота"
    t.string "announce_date", comment: "Дата объявления"
    t.string "subject_type", comment: "предмет закупки"
    t.string "tender_type", comment: "способ закупки"
    t.string "etp_address", comment: "Адрес ЭТП"
    t.string "point_clause", comment: "Пункт положения"
    t.string "tender_type_explanations", limit: 4000, comment: "обоснование выбора способа закупки"
    t.string "explanations_doc", limit: 1000, comment: "Обосновывающий док-т (только для ЕИ)"
    t.string "lot_name", limit: 500, comment: "Наименование лота"
    t.string "organizer", comment: "организатор"
    t.string "qty", comment: "кол-во"
    t.string "cost", comment: "цена руб. без НДС"
    t.string "cost_nds", comment: "Цена, руб. с НДС"
    t.string "product_type", comment: "вид продукции"
    t.string "cost_doc", comment: "Документ определяющий цену"
    t.string "direction", comment: "направление закупки"
    t.string "financing", comment: "источник финансирования"
    t.string "requirements", comment: "Минимально необходимые требования к закупаемой продукции"
    t.string "potential_participants", limit: 4000, comment: "Потенциальные участники"
    t.string "customer", comment: "заказчик"
    t.string "consumer", comment: "потребитель"
    t.string "delivery_date_begin", comment: "Начало поставки"
    t.string "delivery_date_end", comment: "Окончание поставки"
    t.string "monitor_service", comment: "курирующее подразделение"
    t.string "curator", comment: "Куратор"
    t.string "tech_curator", comment: "Технический куратор"
    t.string "bp_item", limit: 1000, comment: "Номер пункта ФБ / Строка бизнес-плана"
    t.text "note", comment: "Примечания"
    t.string "amount_mastery", comment: "освоение без НДС"
    t.string "amount_mastery_nds", comment: "освоение с НДС"
    t.string "amount_finance", comment: "финансирование без НДС"
    t.string "amount_finance_nds", comment: "финансирование с НДС"
    t.string "okved", comment: "Код ОКВЭД2"
    t.string "okdp", comment: "Код ОКПД2"
    t.string "okei", comment: "Код ОКЕИ"
    t.string "okato", comment: "Код ОКАТО"
    t.string "sme_type", comment: "Тип МСП"
    t.string "is_centralize", comment: "Централизованная закупка?"
    t.string "production_unit", comment: "Производственное подразделение"
    t.string "amount_mastery_next_year", comment: "Сумма освоения без НДС в следующем году"
    t.string "amount_mastery_nds_next_year", comment: "Сумма освоения с НДС в следующем году"
  end

  create_table "invest_project_names", id: :serial, force: :cascade, comment: "Внешний справочник инвест. проектов" do |t|
    t.string "name", limit: 1500, null: false, comment: "Наименование инвест. проекта"
    t.string "aqua_id", comment: "Код в ИС Аква"
    t.integer "department_id", null: false, comment: "Ссылка на справочник подразделений"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invest_projects", id: :serial, force: :cascade, comment: "Инвестиционные проекты" do |t|
    t.string "num", comment: "Номер"
    t.string "name", limit: 1500, comment: "Наименование"
    t.string "object_name", comment: "Наименование объекта генерации/программы развития"
    t.date "date_install", comment: "Ввод объекта в эксплуатацию/окончание работ по проекту"
    t.decimal "power_elec_gen", precision: 18, scale: 4, comment: "Мощность электрической генерации, МВт"
    t.decimal "power_thermal_gen", precision: 18, scale: 4, comment: "Мощность тепловой генерации, ГКал/ч"
    t.decimal "power_elec_net", precision: 18, scale: 4, comment: "Мощность электр. сетей, км"
    t.decimal "power_thermal_net", precision: 18, scale: 4, comment: "Мощность тепловых сетей, км"
    t.decimal "power_substation", precision: 18, scale: 4, comment: "Подстанция, МВА"
    t.decimal "amount_financing", precision: 18, scale: 2, comment: "Планируемый объём обязательств по финан. на тек. год, руб. без НДС"
    t.integer "gkpz_year", null: false, comment: "Год ГКПЗ"
    t.integer "department_id", null: false, comment: "ИД потребителя"
    t.integer "project_type_id", null: false, comment: "ИД типа проектов"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invest_project_name_id", comment: "Ссылка на внешний справочник инвест. проектов"
  end

  create_table "link_tender_files", id: :serial, force: :cascade, comment: "Файлы регламентируемых закупок" do |t|
    t.integer "tender_id", null: false, comment: "ИД реглам. закупки"
    t.integer "tender_file_id", null: false, comment: "ИД файла"
    t.text "note", comment: "Примечание"
    t.integer "file_type_id", null: false, comment: "ИД типа документа"
  end

  create_table "local_time_zones", id: :serial, force: :cascade, comment: "Часовые пояса" do |t|
    t.string "name", null: false, comment: "Время"
    t.string "time_zone", null: false, comment: "Часовой пояс"
  end

  create_table "lots", id: :serial, force: :cascade, comment: "Лот" do |t|
    t.integer "num", null: false, comment: "Номер"
    t.string "name", limit: 500, null: false, comment: "Наименование"
    t.integer "tender_id", null: false, comment: "Ссылка на закупку"
    t.integer "rebid_type_id", comment: "Тип переторжки"
    t.integer "plan_lot_id", comment: "Ссылка на лот в планировании"
    t.integer "status_id", null: false, comment: "Статус лота"
    t.integer "subject_type_id", null: false, comment: "Предмет закупки"
    t.integer "gkpz_year", null: false, comment: "Год ГКПЗ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "guarantie_period", comment: "Гарантийный срок"
    t.text "additional_info", comment: "Дополнительные сведения"
    t.text "work_subject", comment: "Предмет работ"
    t.text "work_size", comment: "Объём выполнения работ"
    t.text "work_stages", comment: "Этапы выполнения работ"
    t.text "order_pricing", comment: "Порядок формирования цены"
    t.text "subcontractoring_conditions", comment: "Условия привлечения субподрядчика"
    t.integer "step_increment", comment: "Шаг аукциона"
    t.decimal "guarantie_cost", precision: 18, scale: 2, comment: "Размер обеспечения"
    t.datetime "auction_date_begin", comment: "Дата начала проведения аукциона"
    t.integer "winner_protocol_id", comment: "ID протокола ВП"
    t.integer "prev_id", comment: "Предыдущий ID"
    t.integer "next_id", comment: "Следующий ID"
    t.integer "review_protocol_id", comment: "ID протокола рассмотрения"
    t.integer "root_customer_id", null: false, comment: "Головное подразделение заказчика"
    t.integer "frame_id", comment: "Рамочный конкурс, по результатам которого проводится данная процедура"
    t.integer "rebid_protocol_id", comment: "Протокол рассмотрения"
    t.integer "object_stage_id", comment: "Стадия объекта"
    t.integer "buisness_type_id", comment: "Вид деятельности"
    t.integer "activity_id", default: 32002, comment: "Направление деятельности"
    t.integer "privacy_id", default: 29001, comment: "Секретность"
    t.boolean "is_adjustable_rate", default: false, comment: "Регулируемый тариф (Да / Нет)"
    t.boolean "is_ensure_tenders", default: false, comment: "Закупка в целях обеспечения проведения закупок (Да / Нет)"
    t.text "non_public_reason", comment: "Причина невыполнения сроков публикации"
    t.text "boss_note", comment: "Замечания РАО"
    t.text "note", comment: "Примечания"
    t.boolean "not_lead_contract", default: false, comment: "Не привела к заключению договора"
    t.boolean "no_contract_next_bidder", default: false, comment: "Договор со вторым участником не заключался"
    t.text "non_contract_reason", comment: "Причины невыполнения 20 дневного срока на заключение договора"
    t.integer "registred_bidders_count", comment: "Количество зарегистрированных участников"
    t.boolean "life_cycle", default: false, comment: "Применение критерия стоимость договора жизненного цикла"
    t.integer "main_direction_id", comment: "Главное направление"
    t.uuid "guid", comment: "Глабальный идентификатор"
    t.integer "result_protocol_id", comment: "Протокол о результатах"
    t.integer "sublot_num", comment: "Номер подлота"
    t.integer "sme_type_id", comment: "Отношение к участию МСП"
    t.uuid "plan_lot_guid", comment: "Глобальный идентификатор контрагента"
    t.boolean "fas_appeal", default: false, comment: "По закупке подана жалоба в ФАС"
    t.integer "order_id", comment: "Id поручения"
    t.string "num_plan_eis", limit: 20, comment: "Номер позиции плана на ЕИС"
    t.index ["plan_lot_guid"], name: "i_lots_plan_lot_guid"
    t.index ["plan_lot_id"], name: "i_lots_plan_lot_id"
    t.index ["review_protocol_id"], name: "i_lots_review_protocol_id"
    t.index ["tender_id"], name: "i_lots_tender"
    t.index ["winner_protocol_id"], name: "i_lots_winner_protocol_id"
  end

  create_table "lots_unfair_contractors", id: false, force: :cascade, comment: "Таблица для связи таблицы unfair_contractors и lots" do |t|
    t.integer "lot_id", null: false
    t.integer "unfair_contractor_id", null: false
    t.index ["lot_id"], name: "index_lots_unfair_contractors_on_lot_id"
    t.index ["unfair_contractor_id"], name: "index_lots_unfair_contractors_on_unfair_contractor_id"
  end

  create_table "lots_winner_protocols", id: false, force: :cascade, comment: "Связ. таблица: лоты + протоколы победителя" do |t|
    t.integer "lot_id", null: false, comment: "ИД лота"
    t.integer "winner_protocol_id", null: false, comment: "ИД протокола победителя"
  end

  create_table "main_contacts", id: :serial, force: :cascade do |t|
    t.string "role"
    t.integer "position"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_main_contacts_on_user_id"
  end

  create_table "monitor_services", id: :serial, comment: "Таблица для заполнения курирующих подразделений", force: :cascade, comment: "Таблица для заполнения курирующих подразделений" do |t|
    t.integer "department_id", null: false, comment: "ИД курирующего подразделения"
  end

  create_table "offer_specifications", id: :serial, force: :cascade, comment: "Спецификации предложений" do |t|
    t.integer "offer_id", null: false, comment: "Offer"
    t.integer "specification_id", null: false, comment: "Specification"
    t.decimal "cost", precision: 18, scale: 2, null: false, comment: "Цена"
    t.decimal "cost_nds", precision: 18, scale: 2, null: false, comment: "Цена с НДС"
    t.decimal "final_cost", precision: 18, scale: 2, null: false, comment: "Окончательная цена"
    t.decimal "final_cost_nds", precision: 18, scale: 2, null: false, comment: "Окончательная цена с НДС"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id", "specification_id"], name: "i_offer_specification", unique: true
  end

  create_table "offers", id: :serial, force: :cascade, comment: "Предложения участников" do |t|
    t.integer "lot_id", null: false, comment: "Лот"
    t.integer "bidder_id", null: false, comment: "Участник"
    t.integer "num", null: false, comment: "Номер"
    t.integer "version", null: false, comment: "Версия (0 - последняя,актуальная)"
    t.integer "type_id", null: false, comment: "Статус"
    t.integer "status_id", null: false, comment: "Статус"
    t.integer "rank", comment: "Место в ранжировке"
    t.boolean "is_winer", default: false, comment: "Победитель"
    t.text "conditions", comment: "Существенные условия"
    t.text "note", comment: "Примечания"
    t.text "change_descriptions", comment: "Краткое описание изменений"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rebidded", default: false, null: false, comment: "Участник принимал участие в переторжке или аукционе"
    t.boolean "maker", default: false, null: false, comment: "Участник является производителем"
    t.boolean "absent_auction", comment: "Не явился на процедуру аукциона"
    t.text "final_conditions", comment: "Существенные условия после переторжки"
    t.text "non_contract_reason", comment: "Причины невыполнения 20 дневного срока на заключение договора"
    t.index ["bidder_id", "lot_id", "num", "version"], name: "i_offers_bidder_lot_num_vers"
  end

  create_table "okdp", id: :serial, force: :cascade, comment: "Справочник ОКДП" do |t|
    t.integer "parent_id", comment: "ИД родительской записи"
    t.string "code", null: false, comment: "Код справочника"
    t.string "name", limit: 500, null: false, comment: "Наименование"
    t.string "ancestry", comment: "Служебное поле гема ancestry"
    t.string "ref_type", comment: "Тип ОКДП (OKDP or OKPD2)"
    t.index ["ancestry"], name: "index_okdp_on_ancestry"
  end

  create_table "okdp_etp", primary_key: "code", id: :serial, limit: 255, comment: "код ОКДП", force: :cascade, comment: "Коды ОКДП для ЭТП" do |t|
  end

  create_table "okdp_reform", id: false, force: :cascade, comment: "Соответствия кодов ОКДП и ОКПД2" do |t|
    t.string "old_value", null: false, comment: "Код ОКДП"
    t.string "new_value", null: false, comment: "Код ОКПД2"
  end

  create_table "okdp_sme", primary_key: "code", id: :serial, limit: 255, comment: "код ОКПД2", force: :cascade, comment: "Коды ОКПД2 для МСП" do |t|
  end

  create_table "okdp_sme_etps", id: :serial, comment: "Кода ОКДП для МСП и ЕТП", force: :cascade, comment: "Кода ОКДП для МСП и ЕТП" do |t|
    t.string "code", null: false, comment: "Код ОКДП"
    t.string "okdp_type", null: false, comment: "Тип ОКДП"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "code"], name: "index_okdp_sme_etps_on_id_and_code", unique: true
  end

  create_table "okved", id: :serial, force: :cascade, comment: "Справочник ОКВЕД" do |t|
    t.integer "parent_id", comment: "ИД родительской записи"
    t.string "code", comment: "Код справочника"
    t.string "name", limit: 500, comment: "Наименование"
    t.string "ref_type", comment: "Тип ОКВЭД (OKVED or OKVED2)"
    t.string "ancestry"
    t.index ["ancestry"], name: "index_okved_on_ancestry"
  end

  create_table "okved_reform", id: false, force: :cascade, comment: "Преобразование кодов ОКВЭД и ОКВЭД2" do |t|
    t.string "old_value", null: false, comment: "Код ОКВЭД"
    t.string "new_value", null: false, comment: "Код ОКВЭД2"
  end

  create_table "open_protocol_present_bidders", id: :serial, force: :cascade, comment: "Присутствовашие на процедуре вскрытия конвертов, представители участников" do |t|
    t.integer "open_protocol_id", null: false, comment: "Ссылка на протокол вскрытия"
    t.integer "bidder_id", null: false, comment: "Участник"
    t.string "delegate", null: false, comment: "ФИО представителя"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["open_protocol_id", "bidder_id"], name: "i_protocol_bidder"
  end

  create_table "open_protocol_present_members", id: :serial, force: :cascade, comment: "Лица, присутствовавшие на процедуре вскрытия конвертов" do |t|
    t.integer "open_protocol_id", null: false, comment: "Ссылка на протокол вскрытия"
    t.integer "user_id", null: false, comment: "ФИО"
    t.integer "status_id", null: false, comment: "Статус в комиссии"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["open_protocol_id", "user_id", "status_id"], name: "i_oppm_protocol_user_status", unique: true
  end

  create_table "open_protocols", id: :serial, force: :cascade, comment: "Протоколы вскрытия конвертов" do |t|
    t.string "num", null: false, comment: "Номер"
    t.date "sign_date", null: false, comment: "Дата подписания"
    t.string "sign_city", comment: "Город"
    t.datetime "open_date", null: false, comment: "Дата время"
    t.string "location", comment: "Место"
    t.text "resolve", comment: "Решение"
    t.integer "tender_id", null: false, comment: "Тендер"
    t.integer "clerk_id", comment: "Секретарь ЗК"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "commission_id", comment: "Коммиссия проводившая вскрытие"
    t.index ["tender_id"], name: "i_open_protocols_tender", unique: true
  end

  create_table "order_files", id: :serial, force: :cascade do |t|
    t.string "note"
    t.integer "order_id", null: false
    t.integer "tender_file_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_files_on_order_id"
    t.index ["tender_file_id"], name: "index_order_files_on_tender_file_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.string "num", comment: "Номер поручения"
    t.date "receiving_date", comment: "Дата получения поручения"
    t.date "agreement_date", comment: "Дата согласования поручения"
    t.integer "received_from_user_id", comment: "Приславший поручение"
    t.integer "agreed_by_user_id", comment: "Согласовавший поручение"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders_plan_lots", id: false, force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "plan_lot_id", null: false
    t.index ["order_id", "plan_lot_id"], name: "index_orders_plan_lots_on_order_id_and_plan_lot_id"
  end

  create_table "ownerships", id: :serial, force: :cascade do |t|
    t.string "shortname"
    t.string "fullname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "shortname"], name: "index_ownerships_on_id_and_shortname", unique: true
  end

  create_table "page_files", id: :serial, force: :cascade, comment: "Файлы для wiki" do |t|
    t.integer "page_id", comment: "ИД страницы"
    t.string "wikifile", comment: "Файл"
  end

  create_table "pages", id: :serial, force: :cascade, comment: "Статические страницы" do |t|
    t.string "name", comment: "Заголовок"
    t.string "permalink", comment: "Ссылка"
    t.text "content", comment: "Содержание"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permalink"], name: "index_pages_on_permalink"
  end

  create_table "plan_annual_limits", id: :serial, comment: "Годовые лимиты для ПО", force: :cascade, comment: "Годовые лимиты для ПО" do |t|
    t.integer "plan_lot_id", null: false, comment: "Ссылка на планируемый лот"
    t.integer "year", null: false, comment: "Год"
    t.decimal "cost", precision: 18, scale: 2, null: false, comment: "Лимит, руб. без НДС"
    t.decimal "cost_nds", precision: 18, scale: 2, null: false, comment: "Лимит, руб. без НДС"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plan_lot_contractors", id: :serial, force: :cascade, comment: "Участники по плану" do |t|
    t.integer "plan_lot_id", null: false, comment: "Планируемый лот"
    t.integer "contractor_id", null: false, comment: "Планируемый участник"
    t.index ["plan_lot_id", "contractor_id"], name: "i_planlot_contractor", unique: true
  end

  create_table "plan_lot_non_executions", id: :serial, force: :cascade, comment: "Причины неисполнения стартов" do |t|
    t.uuid "plan_lot_guid", null: false, comment: "План лот гуид"
    t.text "reason", comment: "Пичина"
    t.integer "user_id", null: false, comment: "Автор"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["plan_lot_guid"], name: "i_plne_guid"
    t.index ["user_id"], name: "i_pla_lot_non_exe_use_id"
  end

  create_table "plan_lots", id: :serial, force: :cascade, comment: "Планируемые лоты" do |t|
    t.uuid "guid", null: false, comment: "ГУИД лота"
    t.integer "version", default: 0, null: false, comment: "Версия записи (0 - текущая)"
    t.integer "gkpz_year", null: false, comment: "Год ГКПЗ"
    t.integer "num_tender", null: false, comment: "Номер закупки"
    t.integer "num_lot", null: false, comment: "Номер лота"
    t.string "lot_name", limit: 500, null: false, comment: "Наименование лота"
    t.integer "department_id", comment: "ИД организатора"
    t.integer "tender_type_id", comment: "ИД способа закупки"
    t.string "tender_type_explanations", limit: 4000, comment: "Обоснование выбора способа закупки"
    t.integer "subject_type_id", null: false, comment: "Предмет закупки"
    t.integer "etp_address_id", comment: "ИД адреса ЭТП, на которой будет объявлена закупка"
    t.date "announce_date", null: false, comment: "Дата объявления"
    t.string "explanations_doc", limit: 1000, comment: "Обосновывающий док-т (только для ЕИ)"
    t.string "point_clause", comment: "Пункт положения"
    t.integer "protocol_id", comment: "ИД протокола"
    t.integer "status_id", null: false, comment: "ИД статуса"
    t.integer "commission_id", comment: "ИД комиссии"
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "root_customer_id", null: false, comment: "ИД рутового заказчика"
    t.uuid "additional_to", comment: "ГУИД основной закупки"
    t.integer "state", default: 1, null: false, comment: "Состояние в ГКПЗ: 0 - внеплан, 1 - план"
    t.integer "sme_type_id", comment: "Отношение к участию субъектов малого и среднего предпринимательства"
    t.integer "additional_num", comment: "Номер доп. соглашения"
    t.integer "main_direction_id", comment: "Главное направление"
    t.integer "order1352_id", comment: "Типы закупок из постановления правительства №1352 от 11.12.2014"
    t.uuid "preselection_guid", comment: "GUID закупки предварительного отбора"
    t.integer "regulation_item_id", comment: "Ссылка на пункт положения"
    t.date "charge_date", comment: "Дата направления поручения"
    t.boolean "direct", default: false, comment: "По счету"
    t.boolean "non_eis", default: false, null: false, comment: "Не публикуется в план закупок ЕИС"
    t.boolean "centralized", default: false, comment: "Централизованная?"
    t.index ["guid"], name: "i_plan_lots_guid"
    t.index ["protocol_id"], name: "i_plan_lots_protocol"
  end

  create_table "plan_lots_files", id: :serial, force: :cascade, comment: "Привязка файлов к план. лотам" do |t|
    t.integer "plan_lot_id", null: false, comment: "ИД план. лота"
    t.integer "tender_file_id", null: false, comment: "ИД файла"
    t.text "note", comment: "Комментарий к файлу"
    t.integer "file_type_id", null: false, comment: "Тип файла (в dictionaries)"
    t.index ["plan_lot_id", "tender_file_id"], name: "i7408c718c6c9017b2c9d250f1d1ad", unique: true
  end

  create_table "plan_spec_amounts", id: :serial, force: :cascade, comment: "Планируемые суммы спецификаций" do |t|
    t.integer "plan_specification_id", null: false, comment: "ИД спецификации"
    t.integer "year", null: false, comment: "Год"
    t.decimal "amount_mastery", precision: 18, scale: 2, comment: "Освоение без НДС"
    t.decimal "amount_mastery_nds", precision: 18, scale: 2, comment: "Освоение с НДС"
    t.decimal "amount_finance", precision: 18, scale: 2, comment: "Финансирование без НДС"
    t.decimal "amount_finance_nds", precision: 18, scale: 2, comment: "Финансирование с НДС"
    t.index ["plan_specification_id"], name: "i_plan_spec_amounts_spec_id"
  end

  create_table "plan_spec_production_units", id: false, force: :cascade do |t|
    t.integer "plan_specification_id", null: false
    t.integer "department_id"
    t.index ["plan_specification_id"], name: "index_plan_spec_production_units_on_plan_specification_id"
  end

  create_table "plan_specifications", id: :serial, force: :cascade, comment: "Спецификации лотов" do |t|
    t.integer "plan_lot_id", null: false, comment: "ИД лота"
    t.uuid "guid", null: false, comment: "ГУИД спецификации"
    t.integer "num_spec", null: false, comment: "№ спец."
    t.string "name", limit: 500, null: false, comment: "Наименование спецификации"
    t.integer "qty", null: false, comment: "Кол-во"
    t.decimal "cost", precision: 18, scale: 2, null: false, comment: "Цена, руб. без НДС"
    t.decimal "cost_nds", precision: 18, scale: 2, null: false, comment: "Цена, руб. с НДС"
    t.string "cost_doc", comment: "Документ определяющий цену"
    t.integer "unit_id", comment: "ИД ед. измерения (ОКЕИ)"
    t.integer "okdp_id", comment: "ИД ОКДП"
    t.integer "okved_id", comment: "ИД ОКВЭД"
    t.integer "direction_id", null: false, comment: "ИД направления закупки"
    t.integer "product_type_id", comment: "ИД вида продукции"
    t.integer "financing_id", comment: "ИД источника финансирования"
    t.integer "customer_id", null: false, comment: "ИД заказчика"
    t.integer "consumer_id", null: false, comment: "ИД потребителя"
    t.integer "monitor_service_id", comment: "ИД курирующего подразделения"
    t.integer "invest_project_id", comment: "ИД инвест. проекта"
    t.date "delivery_date_begin", null: false, comment: "Начало поставки"
    t.date "delivery_date_end", null: false, comment: "Окончание поставки"
    t.string "bp_item", limit: 1000, comment: "Номер пункта ФБ / Строка бизнес-плана"
    t.string "requirements", comment: "Минимально необходимые требования к закупаемой продукции"
    t.string "potential_participants", limit: 4000, comment: "Потенциальные участники"
    t.string "curator", comment: "Куратор"
    t.string "tech_curator", comment: "Технический куратор"
    t.text "note", comment: "Примечания"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bp_state_id", comment: "Ссылка на номер бюджетного кодификатора"
    t.index ["guid"], name: "i_plan_specs_guid"
    t.index ["plan_lot_id"], name: "i_pla_spe_pla_lot_id"
  end

  create_table "protocol_files", id: :serial, force: :cascade do |t|
    t.integer "protocol_id", null: false, comment: "Протокол"
    t.integer "tender_file_id", null: false, comment: "Файл"
    t.text "note", comment: "Примечания"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocol_users", id: :serial, force: :cascade do |t|
    t.integer "commission_id"
    t.integer "user_id"
    t.integer "status"
    t.boolean "is_veto"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocols", id: :serial, force: :cascade, comment: "Протоколы" do |t|
    t.string "num", null: false, comment: "Номер протокола"
    t.date "date_confirm", null: false, comment: "Дата протокола"
    t.string "location", comment: "Место проведения"
    t.integer "format_id", null: false, comment: "Форма проведения"
    t.integer "commission_id", null: false, comment: "Закупочный орган"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gkpz_year", null: false, comment: "Год ГКПЗ"
    t.index ["date_confirm"], name: "i_protocols_date_confirm"
  end

  create_table "rebid_protocol_present_bidders", id: :serial, force: :cascade, comment: "Присутствовавшие участники на переторжке" do |t|
    t.integer "rebid_protocol_id", null: false, comment: "Протокол переторжки"
    t.integer "bidder_id", null: false, comment: "Участник"
    t.string "delegate", null: false, comment: "ФИО представителя"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rebid_protocol_id"], name: "i_reb_pro_pre_bid_reb_pro_id"
  end

  create_table "rebid_protocol_present_members", id: :serial, force: :cascade, comment: "Пристуствовавшие члены коммиссиии на переторжке" do |t|
    t.integer "rebid_protocol_id", comment: "Протокол переторжки"
    t.integer "user_id", comment: "Член коммиссии, пользователь системы"
    t.integer "status_id", comment: "Статус его в коммиссии"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rebid_protocol_id"], name: "i_reb_pro_pre_mem_reb_pro_id"
  end

  create_table "rebid_protocols", id: :serial, force: :cascade, comment: "Протоколы переторжки" do |t|
    t.integer "tender_id", null: false, comment: "Тендер"
    t.string "num", null: false, comment: "Номер протокола"
    t.date "confirm_date", null: false, comment: "Дата протокола"
    t.date "vote_date", comment: "Дата подписания"
    t.string "confirm_city", null: false, comment: "Место утверждения протокола"
    t.datetime "rebid_date", null: false, comment: "Дата и время проведения переторжки"
    t.string "location", null: false, comment: "Место проведения переторжки"
    t.text "resolve", null: false, comment: "Решение"
    t.integer "clerk_id", null: false, comment: "Секретарь ЗК"
    t.integer "commission_id", null: false, comment: "Закупочная коммиссия"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tender_id"], name: "i_rebid_protocols_tender_id"
  end

  create_table "reg_item_tender_types", id: :serial, comment: "Join table regulation_items and tender_types", force: :cascade, comment: "Join table regulation_items and tender_types" do |t|
    t.integer "item_id", null: false, comment: "Ссылка на пункт положения"
    t.integer "tender_type_id", null: false, comment: "Ссылка на способ закупки"
  end

  create_table "regulation_items", id: :serial, comment: "Справочник пунктов положения о закупке", force: :cascade, comment: "Справочник пунктов положения о закупке" do |t|
    t.string "num", null: false, comment: "Номер пункта"
    t.text "name", comment: "Наименование"
    t.boolean "is_actual", comment: "Действующий?"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "result_protocol_lots", id: :serial, force: :cascade, comment: "Join Table ResultProtocol to Lot" do |t|
    t.integer "result_protocol_id", null: false, comment: "Протокол о результатах"
    t.integer "lot_id", null: false, comment: "Лот"
    t.index ["lot_id"], name: "i_result_protocol_lots_lot_id"
    t.index ["result_protocol_id"], name: "i_res_pro_lot_res_pro_id"
  end

  create_table "result_protocols", id: :serial, force: :cascade, comment: "Протоколы о результатах" do |t|
    t.integer "tender_id", null: false, comment: "ИД тендера"
    t.string "num", null: false, comment: "Номер"
    t.date "sign_date", null: false, comment: "Дата подписания"
    t.string "sign_city", null: false, comment: "Город"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["tender_id"], name: "i_result_protocols_tender_id"
  end

  create_table "review_lots", id: :serial, force: :cascade, comment: "Связующая таблица для лотов и протоколов рассмотрения" do |t|
    t.integer "lot_id", null: false, comment: "Лот"
    t.integer "review_protocol_id", null: false, comment: "Протокол рассмотрения"
    t.datetime "rebid_date", comment: "Дата вскрытия с переторжкой"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "rebid_place", comment: "Место проведения переторжки"
    t.index ["review_protocol_id"], name: "i_rev_lot_rev_pro_id"
  end

  create_table "review_protocols", id: :serial, force: :cascade, comment: "Протоколы рассмотрения" do |t|
    t.integer "tender_id", null: false, comment: "ИД тендера"
    t.string "num", null: false, comment: "Номер"
    t.date "confirm_date", null: false, comment: "Дата вступления в силу"
    t.date "vote_date", comment: "Дата голосования"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tender_id"], name: "i_review_protocols_tender_id"
  end

  create_table "roles", id: :serial, force: :cascade, comment: "Роли пользователей" do |t|
    t.string "name", null: false, comment: "Наименование (англ)"
    t.string "name_ru", null: false, comment: "Наименование (рус)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 1, null: false, comment: "Порядок загрузки ролей"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "specifications", id: :serial, force: :cascade, comment: "Спецификация" do |t|
    t.integer "num", null: false, comment: "Номер"
    t.string "name", limit: 500, null: false, comment: "Наименование"
    t.integer "qty", null: false, comment: "Кол-во"
    t.decimal "cost", precision: 18, scale: 2, null: false, comment: "Цена без НДС"
    t.decimal "cost_nds", precision: 18, scale: 2, null: false, comment: "Цена с НДС"
    t.boolean "is_public_cost", comment: "Цена опубликована"
    t.integer "unit_id", null: false, comment: "Код ОКЕИ"
    t.integer "lot_id", null: false, comment: "Ссылка на лот"
    t.integer "plan_specification_id", comment: "Ссылка на спецификацию в планировании"
    t.integer "direction_id", null: false, comment: "Направление закупки"
    t.integer "financing_id", null: false, comment: "Источник финансирования"
    t.integer "product_type_id", null: false, comment: "Вид закупаемой продукции"
    t.integer "customer_id", null: false, comment: "Заказчик"
    t.integer "consumer_id", null: false, comment: "Потребитель"
    t.integer "invest_project_id", comment: "Инвестиционный проект"
    t.integer "monitor_service_id", comment: "Курирующее подразделение"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "delivery_date_begin", comment: "Дата начала поставки"
    t.date "delivery_date_end", comment: "Дата окончания поставки"
    t.integer "contact_id", comment: "Контакты заказчика"
    t.integer "frame_id", comment: "Спецификация рамки"
    t.uuid "guid", comment: "Глабальный идентификатор"
    t.uuid "plan_specification_guid", comment: "Глобальный идентификатор плановой спецификации"
    t.index ["lot_id"], name: "i_specifications_lot"
  end

  create_table "sub_contractor_specs", id: :serial, force: :cascade, comment: "Доли субподрядчиков по спецификациям" do |t|
    t.integer "specification_id", null: false, comment: "ИД спецификации"
    t.integer "contract_specification_id", null: false, comment: "ИД спецификации договора"
    t.integer "sub_contractor_id", null: false, comment: "ИД субподрядчика"
    t.decimal "cost", precision: 18, scale: 2, comment: "Цена без НДС"
    t.decimal "cost_nds", precision: 18, scale: 2, comment: "Цена с НДС"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sub_contractors", id: :serial, force: :cascade, comment: "Субподрядчики" do |t|
    t.integer "contract_id", null: false, comment: "ИД договора"
    t.integer "contractor_id", null: false, comment: "ИД контрагента"
    t.string "name", comment: "Предмет договора с субподрядчиком"
    t.date "confirm_date", comment: "Дата заключения договора"
    t.string "num", comment: "Номер договора"
    t.date "begin_date", comment: "Дата начала исполнения"
    t.date "end_date", comment: "Дата окончания исполнения"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscribe_actions", id: :serial, force: :cascade, comment: "События для подписки" do |t|
    t.integer "subscribe_id", null: false, comment: "ИД подписки"
    t.integer "action_id", null: false, comment: "ИД события"
    t.integer "days_before", comment: "Предупреждать за ... дней"
    t.index ["subscribe_id"], name: "i_subscribe_actions"
  end

  create_table "subscribe_notifications", id: :serial, force: :cascade, comment: "Таблица с сообщениями для пользователей" do |t|
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.text "format_html", null: false, comment: "Сообщение в формате HTML"
    t.text "format_email", comment: "Сообщение в формате EMAIL"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "i_subscribe_notifies_user"
  end

  create_table "subscribes", id: :serial, force: :cascade, comment: "Подписки" do |t|
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.uuid "plan_lot_guid", null: false, comment: "ГУИД лота"
    t.text "plan_structure", null: false, comment: "Структура лота в плане"
    t.text "fact_structure", comment: "Структура лота в факте"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme", comment: "Тема подписки"
    t.index ["user_id"], name: "i_subscribes_user"
  end

  create_table "task_statuses", id: :serial, force: :cascade, comment: "Статусы задач" do |t|
    t.string "name", comment: "Наименование"
  end

  create_table "tasks", id: :serial, force: :cascade, comment: "Задачи которые нужно выполнить" do |t|
    t.text "description", comment: "Описание"
    t.integer "priority", comment: "Приоритет"
    t.integer "task_status_id", null: false, comment: "ИД статуса"
    t.text "task_comment", comment: "Комментарий"
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tender_content_offers", id: :serial, force: :cascade, comment: "Требования к составу заявок" do |t|
    t.text "name", null: false, comment: "Наименование"
    t.string "num", null: false, comment: "Номер"
    t.integer "position", default: 100, null: false, comment: "Порядок сортировки"
    t.integer "content_offer_type_id", null: false, comment: "Тип требования"
    t.integer "tender_id", null: false, comment: "Тендер"
    t.index ["tender_id"], name: "i_ten_con_off_ten_id"
  end

  create_table "tender_dates_for_types", id: :serial, comment: "Связь кол-во дней при валидации даты вскрытия конвертов с типом закупки", force: :cascade, comment: "Связь кол-во дней при валидации даты вскрытия конвертов с типом закупки" do |t|
    t.integer "tender_type_id", null: false, comment: "ИД типа закупки"
    t.integer "days", comment: "Кол-во дней"
  end

  create_table "tender_draft_criterions", id: :serial, force: :cascade, comment: "Отборочные критерии" do |t|
    t.integer "num", null: false, comment: "Номер"
    t.text "name", null: false, comment: "Наименование"
    t.integer "tender_id", null: false, comment: "Тендер"
  end

  create_table "tender_eval_criterions", id: :serial, force: :cascade, comment: "Оценочные критерии" do |t|
    t.string "num", null: false, comment: "Номер"
    t.integer "position", default: 100, null: false, comment: "Порядок сортировки"
    t.text "name", null: false, comment: "Наименование"
    t.integer "value", null: false, comment: "Вес"
    t.integer "tender_id", null: false, comment: "Тендер"
  end

  create_table "tender_files", id: :serial, force: :cascade, comment: "Прикреплённые файлы" do |t|
    t.integer "area_id", null: false, comment: "Область использования (расшифровка в константах)"
    t.integer "year", null: false, comment: "Год привязки"
    t.string "document", null: false, comment: "Имя файла документа"
    t.integer "user_id", null: false, comment: "Пользователь владелец"
    t.string "external_filename", comment: "Имя файла во внешинх системах"
    t.string "content_type", null: false, comment: "Content Type"
    t.integer "file_size", null: false, comment: "Размер"
    t.datetime "created_at", null: false, comment: "Дата создания"
  end

  create_table "tender_requests", id: :serial, force: :cascade, comment: "Запрос на разъяснение" do |t|
    t.integer "tender_id", null: false, comment: "Tender"
    t.integer "contractor_id", comment: "Контрагент"
    t.date "register_date", null: false, comment: "Дата получения запроса"
    t.string "inbox_num", limit: 30, null: false, comment: "Номер исх. письма"
    t.date "inbox_date", null: false, comment: "Дата исх. письма"
    t.text "request", comment: "Краткая характеристика запроса на разъяснение"
    t.integer "user_id", comment: "Пользователь, подготовивший ответ"
    t.string "outbox_num", limit: 30, comment: "Номер ответного письма"
    t.date "outbox_date", comment: "Дата ответного письма"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contractor_text", comment: "Наименование контрагента"
    t.index ["tender_id"], name: "i_tender_requests_tender"
  end

  create_table "tender_type_rules", id: false, force: :cascade, comment: "Правила смены способов закупок" do |t|
    t.integer "plan_type_id", null: false, comment: "Планируемый сопсоб"
    t.integer "fact_type_id", null: false, comment: "Фактический способ"
  end

  create_table "tenders", id: :serial, force: :cascade, comment: "Тендер" do |t|
    t.string "num", limit: 70, null: false, comment: "Номер"
    t.string "name", limit: 500, comment: "Наименование"
    t.integer "tender_type_id", null: false, comment: "Способ закупки"
    t.text "tender_type_explanations", comment: "Обоснование выбора способа"
    t.integer "etp_address_id", null: false, comment: "Адрес ЭТП"
    t.integer "commission_id", comment: "Закупочная комиссия"
    t.integer "department_id", null: false, comment: "Организатор"
    t.date "announce_date", null: false, comment: "Дата публикации в СМИ"
    t.string "announce_place", comment: "Место публикации"
    t.datetime "bid_date", null: false, comment: "Дата вскрытия конвертов"
    t.string "bid_place", comment: "Место вскрытия конвертов"
    t.integer "user_id", comment: "Ответственный пользователь"
    t.bigint "oos_num", comment: "Номер закупки на ООС"
    t.bigint "oos_id", comment: "Идентификатор закупки на ООС"
    t.string "etp_num", limit: 255, comment: "Номер закупки на ЭТП"
    t.string "order_num", limit: 70, comment: "№ распоряжения"
    t.date "order_date", comment: "Дата распоряжения"
    t.integer "contact_id", comment: "Контактные данные организатора"
    t.string "confirm_place", comment: "Место утверждения документации"
    t.integer "explanation_period", comment: "Срок предоставления запросов на разъяснение (дней до вскрытия)"
    t.integer "paper_copies", comment: "Количество копий заявок/предложений на бумажном носителе"
    t.integer "digit_copies", comment: "Количество копий заявок/предложений в электронном виде"
    t.integer "life_offer", comment: "Срок действия конкурсной заявки"
    t.date "offer_reception_start", comment: "Дата начала приёма заявок/предложений"
    t.date "offer_reception_stop", comment: "Дата окончания приёма заявок/предложений"
    t.string "review_place", comment: "Место рассмотрения заявок/предложений"
    t.datetime "review_date", comment: "Дата рассмотрения заявок/предложений"
    t.string "summary_place", comment: "Место подведения итогов"
    t.datetime "summary_date", comment: "Дата подведения итогов"
    t.boolean "is_sertification", comment: "Учитывается/не учитывается добровольная сертификация"
    t.boolean "is_guarantie", comment: "Требуется/не требуется обеспечение заявок"
    t.text "guarantie_offer", comment: "Форма обеспечения заявок"
    t.date "guarantie_date_begin", comment: "Срок обеспечения (дата начала)"
    t.date "guarantie_date_end", comment: "Срок обеспечения (дата окончания)"
    t.text "guarantie_making_money", comment: "Порядок внечения денежных средств"
    t.text "guarantie_recvisits", comment: "Реквизиты для перечисления"
    t.text "guarant_criterions", comment: "Требования к гаранту"
    t.boolean "is_multipart", comment: "Допускаются/не допускаются коллективные участники"
    t.integer "alternate_offer", comment: "Количество альтернативных предложений"
    t.text "alternate_offer_aspects", comment: "Аспекты по которым может быть подано альтернативное предложение"
    t.text "maturity", comment: "Срок оплаты"
    t.boolean "is_prepayment", comment: "Допускается/не допускается авансирование"
    t.decimal "prepayment_cost", precision: 18, scale: 2, comment: "Размер аванса руб"
    t.decimal "prepayment_percent", precision: 18, scale: 2, comment: "Размер аванса %"
    t.text "prepayment_aspects", comment: "Условия аванса"
    t.text "prepayment_period_begin", comment: "Срок оплаты аванса"
    t.text "prepayment_period_end", comment: "Срок оплаты оставшейся части"
    t.integer "project_type_id", comment: "Вид проекта договора"
    t.text "project_text", comment: "Текст проекта договора"
    t.text "provide_td", comment: "Порядок предоставления документации"
    t.text "preferences", comment: "Преференции"
    t.text "other_terms", comment: "Иные существенные условия"
    t.integer "contract_period", comment: "Срок заключения договора"
    t.text "prepare_offer", comment: "Порядок подготовки заявок/предложений"
    t.text "provide_offer", comment: "Порядок предоставления заявок/предложений"
    t.boolean "is_gencontractor", comment: "Право участвовать генеральным подрядчикам"
    t.text "contract_guarantie", comment: "Обеспечение исполнения обязательств по договору"
    t.boolean "is_simple_production", comment: "Простая продукция"
    t.text "reason_for_replace", comment: "Причины внесения изменений"
    t.boolean "is_rebid", comment: "Переторжка предусмотрена/не предусмотрена"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failure_period", comment: "Срок отказа от проведения конкурса"
    t.string "offer_reception_place", comment: "Место предоставления конвертов"
    t.integer "local_time_zone_id", comment: "Часовой пояс проведения закупки"
    t.boolean "is_profitable", comment: "Закупка в счет доходных договоров"
    t.boolean "contract_period_type", comment: "0 - календарные дни, 1 - рабочие"
    t.datetime "auction_date", comment: "Дата и время проведение аукциона на b2b"
    t.date "agency_contract_date", comment: "Дата договора на проведение закупки сторонним организатором"
    t.string "agency_contract_num", comment: "Номер договора на проведение закупки сторонним организатором"
    t.string "official_site_num", limit: 25, comment: "Номер закупки на официальном сайте общества"
    t.boolean "hidden_offer", comment: "Использовать ли закрытую подачу предложений"
    t.integer "b2b_classifiers", default: [], comment: "Классификаторы b2b-center", array: true
    t.boolean "price_begin_limited", comment: "Ограничивать предложения участников указанной в извещении стоимостью"
    t.boolean "centralized", default: false, comment: "Централизованная?"
  end

  create_table "unfair_contractors", id: :serial, comment: "Реест недобросовестных контрагентов", force: :cascade, comment: "Реест недобросовестных контрагентов" do |t|
    t.integer "num", null: false, comment: "Номер реестровой записи"
    t.date "date_in", null: false, comment: "Дата включения в реестр"
    t.integer "contractor_id", null: false, comment: "ИД контрагента"
    t.uuid "contractor_guid", null: false
    t.text "contract_info", null: false, comment: "Сведения о договоре"
    t.text "unfair_info", null: false, comment: "Сведения о нарушении"
    t.date "date_out", comment: "Дата исключения из реестра"
    t.text "note", comment: "Примечание"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "unit_subtitles", id: :serial, force: :cascade, comment: "Подразделы справочника ОКЕИ" do |t|
    t.string "name", comment: "Наименование"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "unit_titles", id: :serial, force: :cascade, comment: "Разделы справочника ОКЕИ" do |t|
    t.string "name", comment: "Наименование"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", id: :serial, force: :cascade, comment: "Справочник ОКЕИ" do |t|
    t.string "code", comment: "Код справочника"
    t.string "name", comment: "Наименование"
    t.string "symbol_n", comment: "Сокр. нац. симв."
    t.string "symbol_i", comment: "Сокр. интернац. симв."
    t.string "letter_n", comment: "Сокр. нац. письм."
    t.string "letter_i", comment: "Сокр. интернац. письм."
    t.integer "unit_title_id", comment: "ИД раздела"
    t.integer "unit_subtitle_id", comment: "ИД подраздела"
    t.string "symbol_name", null: false, comment: "Симв. наименование"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_configs", id: :serial, force: :cascade, comment: "Личные настройки пользователя" do |t|
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.string "subscribe_send_time", comment: "Ежедневное время доставки уведомлений по подпискам"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "i_user_configs", unique: true
  end

  create_table "users", id: :serial, force: :cascade, comment: "Пользователи системы" do |t|
    t.string "email", default: "", null: false, comment: "Электронный адрес"
    t.string "surname", limit: 50, null: false, comment: "Фамилия"
    t.string "name", limit: 50, null: false, comment: "Имя"
    t.string "patronymic", limit: 50, null: false, comment: "Отчество"
    t.string "user_job", comment: "Должность"
    t.string "phone_public", limit: 20, comment: "Городской телефон"
    t.string "phone_cell", limit: 20, comment: "Сотовый телефон"
    t.string "phone_office", limit: 20, comment: "Внутриофисный телефон"
    t.string "fax", limit: 20, comment: "Факс"
    t.string "avatar"
    t.integer "department_id", default: 2, null: false, comment: "ИД отдела"
    t.integer "root_dept_id", comment: "Область видимости (головное подразделение)"
    t.boolean "approved", default: false, null: false, comment: "Активировация пользователя"
    t.string "login", default: "", null: false, comment: "Логин"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gender", comment: "Пол (женский, мужской)"
    t.index ["approved"], name: "index_users_on_approved"
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["reset_password_token"], name: "i_users_reset_password_token", unique: true
  end

  create_table "users_plan_lots", id: false, force: :cascade, comment: "Выделенные план. лоты пользователей" do |t|
    t.integer "user_id", null: false, comment: "ИД пользователя"
    t.integer "plan_lot_id", null: false, comment: "ИД план. лота"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "i_versions_item_type_item_id"
  end

  create_table "web_service_logs", id: :serial, comment: "Лог запросов / ответов веб-сервиса", force: :cascade, comment: "Лог запросов / ответов веб-сервиса" do |t|
    t.string "soap_action", null: false, comment: "soap метод"
    t.string "ip", null: false, comment: "IP запроса"
    t.string "remote_ip", null: false, comment: "Originating IP address, usually set by the RemoteIp middleware"
    t.text "request_body", comment: "тело запроса"
    t.text "response_body", comment: "тело ответа"
    t.datetime "created_at", null: false
  end

  create_table "winner_protocol_lots", id: :serial, force: :cascade, comment: "Join Table WinnerProtocol to Lot" do |t|
    t.integer "winner_protocol_id", null: false, comment: "Протокол ВП"
    t.integer "lot_id", null: false, comment: "Лот"
    t.integer "solution_type_id", null: false, comment: "Решение"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_id"], name: "i_wp_lot"
  end

  create_table "winner_protocols", id: :serial, force: :cascade, comment: "Протоколы выбора победителя" do |t|
    t.integer "tender_id", null: false, comment: "ИД тендера"
    t.string "num", null: false, comment: "Номер"
    t.date "confirm_date", null: false, comment: "Дата вступления в силу"
    t.date "vote_date", comment: "Дата голосования"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "violation_reason", comment: "Причины неисполнения срока подведения итогов"
    t.index ["tender_id"], name: "i_winner_protocols_tender_id"
  end

end
