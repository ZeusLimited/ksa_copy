class Shema < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change

    if oracle_adapter?

      create_table "actual_subscribes", temporary: true, id: false, force: true do |t|
        t.integer "subscribe_id", null: false
        t.integer "action_id", null: false
        t.integer "days_before"
      end

      table_comment :actual_subscribes, 'Подписки, требующие отправки'
      column_comment :actual_subscribes, :subscribe_id, 'ИД подписки'
      column_comment :actual_subscribes, :action_id, 'ИД события'
      column_comment :actual_subscribes, :days_before, 'Осталось ... дней'

      create_table "protocol_plan_lots_tmp", temporary: true, id: false, force: true do |t|
        t.integer "user_id"
        t.integer "plan_lot_id"
        t.integer "status_id"
        t.boolean "is_plan"
      end

    end

    create_table "arm_departments", force: true do |t|
      t.string  "arm_id", null: false
      t.string  "name", null: false
      t.integer "department_id", null: false
    end

    table_comment :arm_departments, 'Предприятия в АРМ минэнерго'
    column_comment :arm_departments, :arm_id, 'Идентификатор подразделения в арм минэнерго'
    column_comment :arm_departments, :name, 'Наименование подразделения в арм минэнерго'
    column_comment :arm_departments, :department_id, 'Ссылка на справочник подразделений'

    create_table "assignments", id: false, force: true do |t|
      t.integer "user_id", null: false
      t.integer "role_id", null: false
    end
    table_comment :assignments, 'Связь пользователей с ролями'
    column_comment :assignments, :user_id, 'ИД пользователя'
    column_comment :assignments, :role_id, 'ИД роли'

    create_table "bidder_files", force: true do |t|
      t.integer  "bidder_id", null: false
      t.integer  "tender_file_id", null: false
      t.text     "note"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bidder_files", ["bidder_id", "tender_file_id"], name: "i_bidder_files", unique: true

    table_comment :bidder_files, 'Документы предложения участников'
    column_comment :bidder_files, :bidder_id, 'Участник'
    column_comment :bidder_files, :tender_file_id, 'Файл'
    column_comment :bidder_files, :note, 'Примечания'

    create_table "bidders", force: true do |t|
      t.integer  "tender_id", null: false
      t.integer  "contractor_id", null: false
      t.boolean  "is_presence", default: true
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "bidders", ["tender_id", "contractor_id"], name: "i_bidders_tender_contractor", unique: true

    table_comment :bidders, 'Участник'
    column_comment :bidders, :tender_id, 'Закупка'
    column_comment :bidders, :contractor_id, 'Участник'
    column_comment :bidders, :is_presence, 'Присутствовал на процедуре проведения закупки'

    create_table "cart_lots", id: false, force: true do |t|
      t.integer "user_id", precision: 38, null: false
      t.integer "lot_id",  limit: nil, precision: 38, null: false
    end

    table_comment :cart_lots, 'Выбранные лоты пользователей'
    column_comment :cart_lots, :user_id, 'ИД пользователя'
    column_comment :cart_lots, :lot_id, 'ИД лота'

    create_table "commission_users", force: true do |t|
      t.integer  "commission_id"
      t.integer  "user_id"
      t.integer  "status"
      t.boolean  "is_veto"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
      t.string   "user_job"
    end
    table_comment :commission_users, 'Члены комиссий'
    column_comment :commission_users, :id, ''
    column_comment :commission_users, :commission_id, 'ИД комиссии'
    column_comment :commission_users, :user_id, 'ИД пользователя'
    column_comment :commission_users, :status, 'ИД статуса в комиссии'
    column_comment :commission_users, :is_veto, 'Есть право вето'
    column_comment :commission_users, :user_job, 'Должность (для генерации документации)'

    create_table "commissions", force: true do |t|
      t.string   "name"
      t.integer  "department_id"
      t.integer  "commission_type_id"
      t.boolean  "is_actual"
      t.datetime "created_at",                                    null: false
      t.datetime "updated_at",                                    null: false
    end

    table_comment :commissions, 'Комиссии'
    column_comment :commissions, :id, ''
    column_comment :commissions, :name, 'Наименование'
    column_comment :commissions, :department_id, 'ИД подразделения'
    column_comment :commissions, :commission_type_id, 'ИД типа комиссии'
    column_comment :commissions, :is_actual, 'Актуальность записи'

    create_table "contacts", force: true do |t|
      guid_column t, "legal_aoid", null: false
      guid_column t, "legal_houseid"
      guid_column t, "postal_aoid"
      guid_column t, "postal_houseid"
      t.string   "web"
      t.string   "email"
      t.string   "phone"
      t.string   "fax"
      t.integer  "version", default: 0, null: false
      t.integer  "department_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    table_comment :contacts, 'Контакт'
    column_comment :contacts, :legal_aoid, 'Юридический адрес'
    column_comment :contacts, :legal_houseid, '№ дома'
    column_comment :contacts, :postal_aoid, 'Почтовый адрес'
    column_comment :contacts, :postal_houseid, '№ дома'
    column_comment :contacts, :web, 'Интернет адрес'
    column_comment :contacts, :email, 'e-mail'
    column_comment :contacts, :phone, 'Номер телефона'
    column_comment :contacts, :fax, 'Факс'
    column_comment :contacts, :version, 'Версия'
    column_comment :contacts, :department_id, 'Предприятие/подразделение'

    create_table "content_offers", force: true do |t|
      t.text     "name", null: false
      t.string   "num", null: false
      t.integer  "position", default: 100, null: false
      t.integer  "content_offer_type_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    table_comment :content_offers, 'Справочник требований к составу заявок'
    column_comment :content_offers, :id, ''
    column_comment :content_offers, :name, 'Наименование'
    column_comment :content_offers, :num, 'Номер'
    column_comment :content_offers, :position, 'Порядок сортировки'
    column_comment :content_offers, :content_offer_type_id, 'Тип требования'

    create_table "contract_amounts", force: true do |t|
      t.integer  "contract_specification_id", null: false
      t.integer  "year", null: false
      t.decimal  "amount_finance", precision: 18, scale: 2, null: false
      t.decimal  "amount_finance_nds", precision: 18, scale: 2, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "contract_amounts", ["contract_specification_id"], name: "i_amounts_contract_spec"
    table_comment :contract_amounts, 'Обязательства по договору'
    column_comment :contract_amounts, :contract_specification_id, 'Ссылка на спецификацию договора'
    column_comment :contract_amounts, :year, 'Год'
    column_comment :contract_amounts, :amount_finance, 'финансирование без НДС'
    column_comment :contract_amounts, :amount_finance_nds, 'финансирование с НДС'

    create_table "contract_files", force: true do |t|
      t.integer "contract_id", null: false
      t.integer "tender_file_id", null: false
      t.integer "file_type_id", null: false
      t.text    "note"
    end

    add_index "contract_files", ["contract_id"], name: "i_contract_files_contract"
    table_comment :contract_files, 'Файлы договоров'
    column_comment :contract_files, :contract_id, 'ИД договора'
    column_comment :contract_files, :tender_file_id, 'ИД файла'
    column_comment :contract_files, :file_type_id, 'ИД типа документа'
    column_comment :contract_files, :note, 'Примечание'

    create_table "contract_specifications", force: true do |t|
      t.integer  "contract_id", null: false
      t.integer  "specification_id", null: false
      t.decimal  "cost", precision: 18, scale: 2, null: false
      t.decimal  "cost_nds", precision: 18, scale: 2, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "contract_specifications", ["contract_id", "specification_id"], name: "i_contract_specification", unique: true
    table_comment :contract_specifications, 'Спецификация договора'
    column_comment :contract_specifications, :contract_id, 'Договор'
    column_comment :contract_specifications, :specification_id, 'Спецификация'
    column_comment :contract_specifications, :cost, 'Стоимость договора без НДС'
    column_comment :contract_specifications, :cost_nds, 'Стоимость договора с НДС'

    create_table "contract_terminations", force: true do |t|
      t.integer  "contract_id", null: false
      t.integer  "type_id", null: false
      t.date     "cancel_date", null: false
      t.decimal  "unexec_cost", precision: 18, scale: 2, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "contract_terminations", ["contract_id"], name: "iu_contract_termination", unique: true
    table_comment :contract_terminations, 'Сведения о расторжениях договоров'
    column_comment :contract_terminations, :contract_id, 'Договор'
    column_comment :contract_terminations, :type_id, 'Способ расторжения'
    column_comment :contract_terminations, :cancel_date, 'Дата расторжения'
    column_comment :contract_terminations, :unexec_cost, 'Объем неисполненных обязательств'

    create_table "contractors", force: true do |t|
      t.string   "name",        limit: 500,                                null: false
      t.string   "fullname",    limit: 500,                                null: false
      t.string   "ownership",   limit: 100
      t.string   "inn",         limit: 12
      t.string   "kpp",         limit: 9
      t.string   "ogrn",        limit: 15
      t.string   "okpo",        limit: 10
      t.integer  "status",      default: 0,     null: false
      t.integer  "form",        null: false
      t.text     "legal_addr"
      t.integer  "user_id",     null: false
      t.integer  "prev_id"
      t.integer  "next_id"
      t.boolean  "is_resident",                            default: true
      t.boolean  "is_dzo",                                 default: false
      t.boolean  "is_sme"
      t.datetime "created_at",                                             null: false
      t.datetime "updated_at",                                             null: false
      t.integer  "jsc_form_id"
      t.integer  "sme_type_id"
      t.string   "oktmo",       limit: 11
      guid_column t, "guid"
      t.date     "reg_date"
    end

    table_comment :contractors, 'Контрагенты'
    column_comment :contractors, :name, 'Наименование'
    column_comment :contractors, :fullname, 'Полное наименование'
    column_comment :contractors, :ownership, 'Форма собственности'
    column_comment :contractors, :inn, 'ИНН'
    column_comment :contractors, :kpp, 'КПП'
    column_comment :contractors, :ogrn, 'ОГРН'
    column_comment :contractors, :okpo, 'ОКПО'
    column_comment :contractors, :status, 'Статус записи(0-новая, 1-активная, 2-старая)'
    column_comment :contractors, :form, 'Вид контрагента (0-физ. лицо, 1-юр. лицо, 2-иностран.)'
    column_comment :contractors, :legal_addr, 'Юридический адрес'
    column_comment :contractors, :user_id, 'ИД юзера'
    column_comment :contractors, :prev_id, 'Предыдущий ИД (до переименования)'
    column_comment :contractors, :next_id, 'Следующий ИД (после переименования)'
    column_comment :contractors, :is_resident, 'Резидент?'
    column_comment :contractors, :is_dzo, 'ДЗО?'
    column_comment :contractors, :is_sme, 'Субъект малого и среднего предпринимательства?'
    column_comment :contractors, :jsc_form_id, 'Форма акционерного общества'
    column_comment :contractors, :sme_type_id, 'Малое или среднее предпринимательство'
    column_comment :contractors, :oktmo, 'Код ОКТМО'
    column_comment :contractors, :guid, 'Глобальный идентификатор контрагента'
    column_comment :contractors, :reg_date, 'Дата регистрации'

    create_table "contracts", force: true do |t|
      t.integer  "lot_id",              null: false
      t.string   "num",                                            null: false
      t.date     "confirm_date",                                   null: false
      t.date     "delivery_date_begin",                            null: false
      t.date     "delivery_date_end",                              null: false
      t.integer  "parent_id"
      t.datetime "created_at",                                     null: false
      t.datetime "updated_at",                                     null: false
      t.text     "non_delivery_reason"
      t.integer  "type_id",             null: false
      t.integer  "offer_id"
      t.string   "reg_number"
      t.decimal  "total_cost",          precision: 18, scale: 2
      t.decimal  "total_cost_nds",      precision: 18, scale: 2
    end

    add_index "contracts", ["lot_id"], name: "i_contracts_lot"
    add_index "contracts", ["offer_id"], name: "i_contracts_offer"

    table_comment :contracts, 'Договоры'
    column_comment :contracts, :offer_id, 'ИД победившей оферты'
    column_comment :contracts, :num, 'Номер договора'
    column_comment :contracts, :confirm_date, 'Дата подписания договора'
    column_comment :contracts, :delivery_date_begin, 'Дата начала поставки'
    column_comment :contracts, :delivery_date_end, 'Дата окончания поставки'
    column_comment :contracts, :parent_id, 'Ссылка на основной договор'
    column_comment :contracts, :created_at, ''
    column_comment :contracts, :updated_at, ''
    column_comment :contracts, :non_delivery_reason, 'Причина невыполнения сроков начала поставки'
    column_comment :contracts, :type_id, 'Тип договора (Основной / Доп. на уменьшение)'
    column_comment :contracts, :id, ''
    column_comment :contracts, :lot_id, 'Договоры'
    column_comment :contracts, :reg_number, 'Регистрационный номер'
    column_comment :contracts, :total_cost, 'Общая стоимость договора без НДС'
    column_comment :contracts, :total_cost_nds, 'Общая стоимость договора с НДС'

    create_table "control_plan_lots", force: true do |t|
      guid_column t, "plan_lot_guid", null: false
      t.integer  "user_id", null: false
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end

    add_index "control_plan_lots", ["plan_lot_guid"], name: "i_control_plan_lots_guid", unique: true
    add_index "control_plan_lots", ["user_id"], name: "i_control_plan_lots_user"
    table_comment :control_plan_lots, 'Лоты на контроле'
    column_comment :control_plan_lots, :plan_lot_guid, 'ГУИД лота в планировании'
    column_comment :control_plan_lots, :user_id, 'ИД пользователя, добавившего лот на контроль'

    create_table "covers", force: true do |t|
      t.integer  "bidder_id", null: false
      t.datetime "register_time"
      t.string   "register_num"
      t.integer  "type_id", null: false
      t.string   "delegate"
      t.string   "provision"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end

    add_index "covers", ["bidder_id"], name: "i_covers_bidder"
    table_comment :covers, 'Конверт'
    column_comment :covers, :register_time, 'Дата и время'
    column_comment :covers, :register_num, 'Регистрационный номер'
    column_comment :covers, :type_id, 'Пометка'
    column_comment :covers, :delegate, 'ФИО представителя'
    column_comment :covers, :provision, 'Форма предоставления'
    column_comment :covers, :bidder_id, 'Участник'

    create_table "criterions", force: true do |t|
      t.string   "type_criterion",                                          null: false
      t.string   "list_num",                                                null: false
      t.integer  "position", default: 100, null: false
      t.text     "name",                                                    null: false
      t.datetime "created_at",                                              null: false
      t.datetime "updated_at",                                              null: false
    end

    table_comment :criterions, 'Критерии отбора/оценки'
    column_comment :criterions, :type_criterion, 'Тип критерия (отбор/оценка)'
    column_comment :criterions, :list_num, 'Номер в списке'
    column_comment :criterions, :position, 'Позиция сортировки'
    column_comment :criterions, :name, 'Наименование'

    create_table "declensions", force: true do |t|
      t.integer  "content_id"
      t.string   "content_type"
      t.string   "name_r"
      t.string   "name_d"
      t.string   "name_v"
      t.string   "name_t"
      t.string   "name_p"
      t.datetime "created_at",                              null: false
      t.datetime "updated_at",                              null: false
    end

    table_comment :declensions, 'Склонения'
    column_comment :declensions, :name_r, 'Родительный'
    column_comment :declensions, :name_d, 'Дательный'
    column_comment :declensions, :name_v, 'Винительный'
    column_comment :declensions, :name_t, 'Творительный'
    column_comment :declensions, :name_p, 'Предложный'

    create_table "departments", force: true do |t|
      t.integer  "parent_dept_id"
      t.string   "name"
      t.integer  "position"
      t.text     "legal_address"
      t.text     "fact_address"
      t.boolean  "is_customer"
      t.boolean  "is_organizer"
      t.integer  "etp_id"
      t.datetime "created_at",                                             null: false
      t.datetime "updated_at",                                             null: false
      t.string   "ancestry"
      t.string   "fullname"
      t.decimal  "tender_cost_limit",             precision: 18, scale: 2
      t.string   "inn",               limit: 10
      t.string   "kpp",               limit: 9
      t.string   "ownership",         limit: 100
    end

    add_index "departments", ["ancestry"], name: "index_departments_on_ancestry"

    table_comment :departments, 'Подразделения'
    column_comment :departments, :inn, 'ИНН'
    column_comment :departments, :kpp, 'КПП'
    column_comment :departments, :ownership, 'Форма собственности'
    column_comment :departments, :parent_dept_id, 'ИД родителя'
    column_comment :departments, :name, 'Наименование'
    column_comment :departments, :position, 'Порядок сортировки'
    column_comment :departments, :legal_address, 'Юридический адрес'
    column_comment :departments, :fact_address, 'Фактический адрес'
    column_comment :departments, :is_customer, 'Может быть заказчиком?'
    column_comment :departments, :is_organizer, 'Может быть организатором?'
    column_comment :departments, :etp_id, 'Код на ЭТП'
    column_comment :departments, :ancestry, 'Служебное поле гема ancestry'
    column_comment :departments, :fullname, 'Полное наименование'
    column_comment :departments, :tender_cost_limit, 'Доступный лимит с НДС'

    create_table "dests_experts", id: false, force: true do |t|
      t.integer "destination_id", precision: 38, null: false
      t.integer "expert_id", null: false
    end

    table_comment :dests_experts, 'Связ. таблица: направления оценки предложения и эксперты'
    column_comment :dests_experts, :destination_id, 'направление оценки предложения'
    column_comment :dests_experts, :expert_id, 'эксперт'

    create_table "dests_tender_draft_crits", id: false, force: true do |t|
      t.integer "dictionary_id",             limit: nil, precision: 38, null: false
      t.integer "tender_draft_criterion_id", precision: 38, null: false
    end

    table_comment :dests_tender_draft_crits, 'Связ. таблица: направления оценки предложения и отборочные критерии'
    column_comment :dests_tender_draft_crits, :dictionary_id, 'направление оценки предложения'
    column_comment :dests_tender_draft_crits, :tender_draft_criterion_id, 'отборочный критерий'

    create_table "dictionaries", primary_key: "ref_id", force: true do |t|
      t.string   "ref_type"
      t.string   "name"
      t.string   "fullname",       limit: 4000
      t.boolean  "is_actual"
      t.integer  "position"
      t.string   "stylename_html"
      t.string   "stylename_docx"
      t.string   "stylename_xlsx"
      t.datetime "created_at",                                 null: false
      t.datetime "updated_at",                                 null: false
    end

    add_index "dictionaries", ["ref_type"], name: "index_dictionaries_on_ref_type"

    table_comment :dictionaries, 'Справочники'
    column_comment :dictionaries, :ref_id, 'ИД'
    column_comment :dictionaries, :ref_type, 'Тип справочника'
    column_comment :dictionaries, :name, 'Краткое наименование'
    column_comment :dictionaries, :fullname, 'Полное наименование'
    column_comment :dictionaries, :is_actual, 'Актуальность записи'
    column_comment :dictionaries, :position, 'Порядок сортировки'
    column_comment :dictionaries, :stylename_html, 'Стиль HTML'
    column_comment :dictionaries, :stylename_docx, 'Стиль DOCX'
    column_comment :dictionaries, :stylename_xlsx, 'Стиль XLSX'

    create_table "doc_takers", force: true do |t|
      t.integer  "contractor_id", null: false
      t.integer  "tender_id", null: false
      t.date     "register_date"
      t.string   "reason",        limit: 1000
      t.datetime "created_at",                                null: false
      t.datetime "updated_at",                                null: false
    end

    add_index "doc_takers", ["contractor_id", "tender_id"], name: "i_doc_takers_contractor_tender", unique: true

    table_comment :doc_takers, 'Лицо получившее конкурсную документацию'
    column_comment :doc_takers, :id, ''
    column_comment :doc_takers, :contractor_id, 'Наименование'
    column_comment :doc_takers, :tender_id, 'Закупка'
    column_comment :doc_takers, :register_date, 'Дата регистрации'
    column_comment :doc_takers, :reason, 'Основание (письмо от ... исх. № ...)'

    create_table "draft_opinions", force: true do |t|
      t.integer  "criterion_id", null: false
      t.integer  "expert_id", null: false
      t.integer  "offer_id", null: false
      t.boolean  "vote"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "draft_opinions", ["expert_id"], name: "i_draft_opinions_expert"
    add_index "draft_opinions", ["offer_id"], name: "i_draft_opinions_offer"

    table_comment :draft_opinions, 'Оценка по отборочным критериям'
    column_comment :draft_opinions, :criterion_id, 'Критерий'
    column_comment :draft_opinions, :expert_id, 'Эксперт'
    column_comment :draft_opinions, :offer_id, 'Оферта'
    column_comment :draft_opinions, :vote, 'Оценка'
    column_comment :draft_opinions, :description, 'Пояснения'

    create_table "experts", force: true do |t|
      t.integer  "tender_id", null: false
      t.integer  "user_id", null: false
      t.datetime "created_at",                            null: false
      t.datetime "updated_at",                            null: false
    end

    add_index "experts", ["tender_id", "user_id"], name: "i_experts_tender_user", unique: true

    table_comment :experts, 'Эксперты'
    column_comment :experts, :tender_id, 'Закупка'
    column_comment :experts, :user_id, 'Эксперт'

    reversible do |dir|
      dir.up do
        if oracle_adapter?
          execute <<-SQL
            CREATE TABLE fias_addrs(
              AOID RAW(16) NOT NULL ENABLE,
              AOGUID RAW(16) NOT NULL ENABLE,
              PARENTGUID RAW(16),
              PREVID RAW(16),
              NEXTID RAW(16),
              AOLEVEL NUMBER(38,0) NOT NULL ENABLE,
              FORMALNAME VARCHAR2(120 CHAR) NOT NULL ENABLE,
              OFFNAME VARCHAR2(120 CHAR),
              SHORTNAME VARCHAR2(10 CHAR) NOT NULL ENABLE,
              OKATO VARCHAR2(11 CHAR),
              OKTMO VARCHAR2(11 CHAR),
              REGIONCODE VARCHAR2(2 CHAR) NOT NULL ENABLE,
              POSTALCODE VARCHAR2(6 CHAR),
              ACTSTATUS NUMBER(1,0) NOT NULL ENABLE,
              FULLNAME VARCHAR2(1000 CHAR),
              CONSTRAINT fias_addrs_pkey PRIMARY KEY (AOID)
            )
          SQL
          execute <<-SQL
            CREATE TABLE fias_houses(
              HOUSEID RAW(16) NOT NULL ENABLE,
              AOGUID RAW(16) NOT NULL ENABLE,
              HOUSEGUID RAW(16) NOT NULL ENABLE,
              BUILDNUM VARCHAR2(10 CHAR),
              HOUSENUM VARCHAR2(20 CHAR),
              OKATO VARCHAR2(11 CHAR),
              OKTMO VARCHAR2(11 CHAR),
              POSTALCODE VARCHAR2(6 CHAR),
              STRUCNUM VARCHAR2(10 CHAR),
              ENDDATE DATE NOT NULL ENABLE,
              FULLNUM VARCHAR2(40 CHAR) NOT NULL ENABLE,
              CONSTRAINT fias_houses_pkey PRIMARY KEY (HOUSEID)
            )
          SQL
        else
          execute <<-SQL
            CREATE TABLE fias_addrs(
              aoid uuid NOT NULL,
              aoguid uuid NOT NULL,
              parentguid uuid,
              previd uuid,
              nextid uuid,
              aolevel integer NOT NULL,
              formalname character varying(120) NOT NULL,
              offname character varying(120),
              shortname character varying(10) NOT NULL,
              okato character varying(11),
              oktmo character varying(11),
              regioncode character varying(2) NOT NULL,
              postalcode character varying(6),
              actstatus boolean NOT NULL,
              fullname character varying(1000),
              CONSTRAINT fias_addrs_pkey PRIMARY KEY (aoid)
            )
          SQL
          execute <<-SQL
            CREATE TABLE fias_houses(
              houseid uuid NOT NULL,
              aoguid uuid NOT NULL,
              houseguid uuid NOT NULL,
              buildnum character varying(10),
              housenum character varying(20),
              okato character varying(11),
              oktmo character varying(11),
              postalcode character varying(6),
              strucnum character varying(10),
              enddate date NOT NULL,
              fullnum character varying(40) NOT NULL,
              CONSTRAINT fias_houses_pkey PRIMARY KEY (houseid)
            )
          SQL
        end
      end
      dir.down do
        drop_table :fias_addrs
        drop_table :fias_houses
      end
    end

    table_comment :fias_addrs, 'ФИАС адреса'
    column_comment :fias_addrs, :aoguid, 'ГУИД адресного объекта'
    column_comment :fias_addrs, :parentguid, 'ИД родительского объекта'
    column_comment :fias_addrs, :previd, 'ИД предыдущей исторической записи'
    column_comment :fias_addrs, :nextid, 'ИД последующей исторической записи'
    column_comment :fias_addrs, :aolevel, 'Уровень адресного объекта'
    column_comment :fias_addrs, :formalname, 'Формализованное наименование'
    column_comment :fias_addrs, :offname, 'Официальное наименование'
    column_comment :fias_addrs, :shortname, 'Краткое наименование типа объекта'
    column_comment :fias_addrs, :okato, 'ОКАТО'
    column_comment :fias_addrs, :oktmo, 'ОКТМО'
    column_comment :fias_addrs, :regioncode, 'Код региона'
    column_comment :fias_addrs, :postalcode, 'Почтовый индекс'
    column_comment :fias_addrs, :actstatus, 'Статус актуальности'
    column_comment :fias_addrs, :fullname, 'Полный адрес (со всеми уровнями)'

    add_index "fias_houses", ["aoguid"], name: "index_fias_houses_on_aoguid"

    table_comment :fias_houses, 'ФИАС дома'
    column_comment :fias_houses, :aoguid, 'ГУИД родительского объекта (улицы, города и т.п.)'
    column_comment :fias_houses, :houseguid, 'ГУИД дома'
    column_comment :fias_houses, :buildnum, 'Номер корпуса'
    column_comment :fias_houses, :housenum, 'Номер дома'
    column_comment :fias_houses, :okato, 'ОКАТО'
    column_comment :fias_houses, :oktmo, 'ОКТМО'
    column_comment :fias_houses, :postalcode, 'Почтовый индекс'
    column_comment :fias_houses, :strucnum, 'Номер строения'
    column_comment :fias_houses, :enddate, 'Окончание действия записи'
    column_comment :fias_houses, :fullnum, 'Полный номер дома (дом+корпус+строение)'

    create_table "fias_plan_specifications", force: true do |t|
      guid_column t, "houseid"
      t.integer "plan_specification_id", precision: 38, null: false
      guid_column t, "addr_aoid", null: false
    end

    table_comment :fias_plan_specifications, 'Адреса спецификаций'
    column_comment :fias_plan_specifications, :houseid, 'ГУИД дома'
    column_comment :fias_plan_specifications, :plan_specification_id, 'ИД спецификации'
    column_comment :fias_plan_specifications, :addr_aoid, 'ГУИД адреса'

    create_table "fias_socrbases", id: false, force: true do |t|
      t.string  "scname",   limit: 10
      t.string  "socrname", limit: 50, null: false
      t.boolean "is_first",            null: false
      t.boolean "need_dot",            null: false
    end

    table_comment :fias_socrbases, 'Типы адресных объектов'
    column_comment :fias_socrbases, :scname, 'Краткое наименоание'
    column_comment :fias_socrbases, :socrname, 'Полное наименование'
    column_comment :fias_socrbases, :is_first, 'Должно идити перед наименованием объекта?'
    column_comment :fias_socrbases, :need_dot, 'Нужна ли точка после наименования?'

    create_table "fias_specifications", force: true do |t|
      guid_column t, "addr_aoid", null: false
      guid_column t, "houseid"
      t.integer "specification_id", null: false
    end

    table_comment :fias_specifications, 'Адреса спецификаций'
    column_comment :fias_specifications, :addr_aoid, 'ГУИД адреса'
    column_comment :fias_specifications, :houseid, 'ГУИД дома'
    column_comment :fias_specifications, :specification_id, 'ИД спецификации'

    create_table "foreign_tender_types", force: true do |t|
      t.integer "tender_type_id", null: false
      t.boolean "is_etp"
      t.string  "foreign_type", null: false
      t.string  "foreign_type_code", null: false
    end

    table_comment :foreign_tender_types, 'Внешние коды способов закупок'
    column_comment :foreign_tender_types, :id, ''
    column_comment :foreign_tender_types, :tender_type_id, 'Код способа закупки в системе ТОРГ'
    column_comment :foreign_tender_types, :is_etp, 'На ЭТП?'
    column_comment :foreign_tender_types, :foreign_type, 'Внешняя система'
    column_comment :foreign_tender_types, :foreign_type_code, 'Код способа закупки во внешней системе'

    create_table "import_lots", id: false, force: true do |t|
      t.integer "num", null: false
      t.integer "user_id", null: false
      t.string  "gkpz_year"
      t.string  "num_tender"
      t.string  "num_lot"
      t.string  "announce_date"
      t.string  "subject_type"
      t.string  "tender_type"
      t.string  "etp_address"
      t.string  "point_clause"
      t.string  "tender_type_explanations", limit: 4000
      t.string  "explanations_doc",         limit: 1000
      t.string  "lot_name",                 limit: 500
      t.string  "organizer"
      t.string  "qty"
      t.string  "cost"
      t.string  "cost_nds"
      t.string  "product_type"
      t.string  "cost_doc"
      t.string  "direction"
      t.string  "financing"
      t.string  "requirements"
      t.string  "potential_participants",   limit: 4000
      t.string  "customer"
      t.string  "consumer"
      t.string  "delivery_date_begin"
      t.string  "delivery_date_end"
      t.string  "monitor_service"
      t.string  "curator"
      t.string  "tech_curator"
      t.string  "bp_item",                  limit: 1000
      t.text    "note"
      t.string  "amount_mastery"
      t.string  "amount_mastery_nds"
      t.string  "amount_finance"
      t.string  "amount_finance_nds"
    end

    table_comment :import_lots, 'Для импорта строк лотов из Excel'
    column_comment :import_lots, :num, 'Номер строки'
    column_comment :import_lots, :user_id, 'ИД пользователя'
    column_comment :import_lots, :gkpz_year, 'Год ГКПЗ'
    column_comment :import_lots, :num_tender, 'номер закупки'
    column_comment :import_lots, :num_lot, 'номер лота'
    column_comment :import_lots, :announce_date, 'Дата объявления'
    column_comment :import_lots, :subject_type, 'предмет закупки'
    column_comment :import_lots, :tender_type, 'способ закупки'
    column_comment :import_lots, :etp_address, 'Адрес ЭТП'
    column_comment :import_lots, :point_clause, 'Пункт положения'
    column_comment :import_lots, :tender_type_explanations, 'обоснование выбора способа закупки'
    column_comment :import_lots, :explanations_doc, 'Обосновывающий док-т (только для ЕИ)'
    column_comment :import_lots, :lot_name, 'Наименование лота'
    column_comment :import_lots, :organizer, 'организатор'
    column_comment :import_lots, :qty, 'кол-во'
    column_comment :import_lots, :cost, 'цена руб. без НДС'
    column_comment :import_lots, :cost_nds, 'Цена, руб. с НДС'
    column_comment :import_lots, :product_type, 'вид продукции'
    column_comment :import_lots, :cost_doc, 'Документ определяющий цену'
    column_comment :import_lots, :direction, 'направление закупки'
    column_comment :import_lots, :financing, 'источник финансирования'
    column_comment :import_lots, :requirements, 'Минимально необходимые требования к закупаемой продукции'
    column_comment :import_lots, :potential_participants, 'Потенциальные участники'
    column_comment :import_lots, :customer, 'заказчик'
    column_comment :import_lots, :consumer, 'потребитель'
    column_comment :import_lots, :delivery_date_begin, 'Начало поставки'
    column_comment :import_lots, :delivery_date_end, 'Окончание поставки'
    column_comment :import_lots, :monitor_service, 'курирующее подразделение'
    column_comment :import_lots, :curator, 'Куратор'
    column_comment :import_lots, :tech_curator, 'Технический куратор'
    column_comment :import_lots, :bp_item, 'Номер пункта ФБ / Строка бизнес-плана'
    column_comment :import_lots, :note, 'Примечания'
    column_comment :import_lots, :amount_mastery, 'освоение без НДС'
    column_comment :import_lots, :amount_mastery_nds, 'освоение с НДС'
    column_comment :import_lots, :amount_finance, 'финансирование без НДС'
    column_comment :import_lots, :amount_finance_nds, 'финансирование с НДС'

    create_table "invest_project_names", force: true do |t|
      t.string   "name",          limit: 1500,                null: false
      t.string   "aqua_id"
      t.integer  "department_id", null: false
      t.datetime "created_at",                                null: false
      t.datetime "updated_at",                                null: false
    end

    table_comment :invest_project_names, 'Внешний справочник инвест. проектов'
    column_comment :invest_project_names, :name, 'Наименование инвест. проекта'
    column_comment :invest_project_names, :aqua_id, 'Код в ИС Аква'
    column_comment :invest_project_names, :department_id, 'Ссылка на справочник подразделений'

    create_table "invest_projects", force: true do |t|
      t.string   "num"
      t.string   "name",                   limit: 1500
      t.string   "object_name"
      t.date     "date_install"
      t.decimal  "power_elec_gen",                      precision: 18, scale: 4
      t.decimal  "power_thermal_gen",                   precision: 18, scale: 4
      t.decimal  "power_elec_net",                      precision: 18, scale: 4
      t.decimal  "power_thermal_net",                   precision: 18, scale: 4
      t.decimal  "power_substation",                    precision: 18, scale: 4
      t.decimal  "amount_financing",                    precision: 18, scale: 2
      t.integer  "gkpz_year", null: false
      t.integer  "department_id",           null: false
      t.integer  "project_type_id",           null: false
      t.datetime "created_at",                                                   null: false
      t.datetime "updated_at",                                                   null: false
      t.integer  "invest_project_name_id"
    end

    table_comment :invest_projects, 'Инвестиционные проекты'
    column_comment :invest_projects, :num, 'Номер'
    column_comment :invest_projects, :name, 'Наименование'
    column_comment :invest_projects, :object_name, 'Наименование объекта генерации/программы развития'
    column_comment :invest_projects, :date_install, 'Ввод объекта в эксплуатацию/окончание работ по проекту'
    column_comment :invest_projects, :power_elec_gen, 'Мощность электрической генерации, МВт'
    column_comment :invest_projects, :power_thermal_gen, 'Мощность тепловой генерации, ГКал/ч'
    column_comment :invest_projects, :power_elec_net, 'Мощность электр. сетей, км'
    column_comment :invest_projects, :power_thermal_net, 'Мощность тепловых сетей, км'
    column_comment :invest_projects, :power_substation, 'Подстанция, МВА'
    column_comment :invest_projects, :amount_financing, 'Планируемый объём обязательств по финан. на тек. год, руб. без НДС'
    column_comment :invest_projects, :gkpz_year, 'Год ГКПЗ'
    column_comment :invest_projects, :department_id, 'ИД потребителя'
    column_comment :invest_projects, :project_type_id, 'ИД типа проектов'
    column_comment :invest_projects, :created_at, ''
    column_comment :invest_projects, :updated_at, ''
    column_comment :invest_projects, :invest_project_name_id, 'Ссылка на внешний справочник инвест. проектов'

    create_table "link_tender_files", force: true do |t|
      t.integer "tender_id", null: false
      t.integer "tender_file_id", null: false
      t.text    "note"
      t.integer "file_type_id", null: false
    end

    table_comment :link_tender_files, 'Файлы регламентируемых закупок'
    column_comment :link_tender_files, :tender_id, 'ИД реглам. закупки'
    column_comment :link_tender_files, :tender_file_id, 'ИД файла'
    column_comment :link_tender_files, :note, 'Примечание'
    column_comment :link_tender_files, :file_type_id, 'ИД типа документа'

    create_table "local_time_zones", force: true do |t|
      t.string "name",      null: false
      t.string "time_zone", null: false
    end

    table_comment :local_time_zones, 'Часовые пояса'
    column_comment :local_time_zones, :name, 'Время'
    column_comment :local_time_zones, :time_zone, 'Часовой пояс'

    create_table "lots", force: true do |t|
      t.integer  "num",                         null: false
      t.string   "name",                        limit: 500,                                          null: false
      t.integer  "tender_id",                   null: false
      t.integer  "rebid_type_id"
      t.integer  "plan_lot_id"
      t.integer  "status_id",                   null: false
      t.integer  "subject_type_id",             null: false
      t.integer  "gkpz_year",                   null: false
      t.datetime "created_at",                                                                       null: false
      t.datetime "updated_at",                                                                       null: false
      t.text     "guarantie_period"
      t.text     "additional_info"
      t.text     "work_subject"
      t.text     "work_size"
      t.text     "work_stages"
      t.text     "order_pricing"
      t.text     "subcontractoring_conditions"
      t.integer  "step_increment"
      t.decimal  "guarantie_cost",                          precision: 18, scale: 2
      t.datetime "auction_date_begin"
      t.integer  "winner_protocol_id"
      t.integer  "prev_id"
      t.integer  "next_id"
      t.integer  "review_protocol_id"
      t.integer  "root_customer_id",                           null: false
      t.integer  "frame_id"
      t.integer  "rebid_protocol_id"
      t.integer  "object_stage_id"
      t.integer  "buisness_type_id"
      t.integer  "activity_id", default: 32002
      t.integer  "privacy_id",  default: 29001
      t.boolean  "is_adjustable_rate",                                               default: false
      t.boolean  "is_ensure_tenders",                                                default: false
      t.text     "non_public_reason"
      t.text     "boss_note"
      t.text     "note"
      t.boolean  "not_lead_contract",                                                default: false, null: false
      t.boolean  "no_contract_next_bidder",                                          default: false, null: false
      t.text     "non_contract_reason"
      t.integer  "registred_bidders_count"
      t.boolean  "life_cycle",                                                       default: false
      t.integer  "main_direction_id"
      guid_column t, "guid"
      t.integer  "result_protocol_id"
      t.integer  "sublot_num"
      t.integer  "sme_type_id"
    end

    add_index "lots", ["review_protocol_id"], name: "i_lots_review_protocol_id"
    add_index "lots", ["tender_id"], name: "i_lots_tender"
    add_index "lots", ["winner_protocol_id"], name: "i_lots_winner_protocol_id"

    table_comment :lots, 'Лот'
    column_comment :lots, :num, 'Номер'
    column_comment :lots, :name, 'Наименование'
    column_comment :lots, :tender_id, 'Ссылка на закупку'
    column_comment :lots, :rebid_type_id, 'Тип переторжки'
    column_comment :lots, :plan_lot_id, 'Ссылка на лот в планировании'
    column_comment :lots, :status_id, 'Статус лота'
    column_comment :lots, :subject_type_id, 'Предмет закупки'
    column_comment :lots, :gkpz_year, 'Год ГКПЗ'
    column_comment :lots, :guarantie_period, 'Гарантийный срок'
    column_comment :lots, :additional_info, 'Дополнительные сведения'
    column_comment :lots, :work_subject, 'Предмет работ'
    column_comment :lots, :work_size, 'Объём выполнения работ'
    column_comment :lots, :work_stages, 'Этапы выполнения работ'
    column_comment :lots, :order_pricing, 'Порядок формирования цены'
    column_comment :lots, :subcontractoring_conditions, 'Условия привлечения субподрядчика'
    column_comment :lots, :step_increment, 'Шаг аукциона'
    column_comment :lots, :guarantie_cost, 'Размер обеспечения'
    column_comment :lots, :auction_date_begin, 'Дата начала проведения аукциона'
    column_comment :lots, :winner_protocol_id, 'ID протокола ВП'
    column_comment :lots, :review_protocol_id, 'ID протокола рассмотрения'
    column_comment :lots, :prev_id, 'Предыдущий ID'
    column_comment :lots, :next_id, 'Следующий ID'
    column_comment :lots, :root_customer_id, 'Головное подразделение заказчика'
    column_comment :lots, :frame_id, 'Рамочный конкурс, по результатам которого проводится данная процедура'
    column_comment :lots, :rebid_protocol_id, 'Протокол рассмотрения'
    column_comment :lots, :object_stage_id, 'Стадия объекта'
    column_comment :lots, :buisness_type_id, 'Вид деятельности'
    column_comment :lots, :activity_id, 'Направление деятельности'
    column_comment :lots, :privacy_id, 'Секретность'
    column_comment :lots, :is_adjustable_rate, 'Регулируемый тариф (Да / Нет)'
    column_comment :lots, :is_ensure_tenders, 'Закупка в целях обеспечения проведения закупок (Да / Нет)'
    column_comment :lots, :non_public_reason, 'Причина невыполнения сроков публикации'
    column_comment :lots, :boss_note, 'Замечания РАО'
    column_comment :lots, :note, 'Примечания'
    column_comment :lots, :not_lead_contract, 'Не привела к заключению договора'
    column_comment :lots, :no_contract_next_bidder, 'Договор со вторым участником не заключался'
    column_comment :lots, :non_contract_reason, 'Причины невыполнения 20 дневного срока на заключение договора'
    column_comment :lots, :registred_bidders_count, 'Количество зарегистрированных участников'
    column_comment :lots, :guid, 'Глабальный идентификатор'
    column_comment :lots, :life_cycle, 'Применение критерия стоимость договора жизненного цикла'
    column_comment :lots, :main_direction_id, 'Главное направление'
    column_comment :lots, :result_protocol_id, 'Протокол о результатах'
    column_comment :lots, :sublot_num, 'Номер подлота'
    column_comment :lots, :sme_type_id, 'Отношение к участию МСП'

    create_table "lots_winner_protocols", id: false, force: true do |t|
      t.integer "lot_id",             limit: nil, precision: 38, null: false
      t.integer "winner_protocol_id", precision: 38, null: false
    end

    table_comment :lots_winner_protocols, 'Связ. таблица: лоты + протоколы победителя'
    column_comment :lots_winner_protocols, :lot_id, 'ИД лота'
    column_comment :lots_winner_protocols, :winner_protocol_id, 'ИД протокола победителя'

    create_table "offer_specifications", force: true do |t|
      t.integer  "offer_id",           null: false
      t.integer  "specification_id", precision: 38,           null: false
      t.decimal  "cost",                         precision: 18, scale: 2, null: false
      t.decimal  "cost_nds",                     precision: 18, scale: 2, null: false
      t.decimal  "final_cost",                   precision: 18, scale: 2, null: false
      t.decimal  "final_cost_nds",               precision: 18, scale: 2, null: false
      t.datetime "created_at",                                            null: false
      t.datetime "updated_at",                                            null: false
    end

    add_index "offer_specifications", ["offer_id", "specification_id"], name: "i_offer_specification", unique: true

    table_comment :offer_specifications, 'Спецификации предложений'
    column_comment :offer_specifications, :offer_id, 'Offer'
    column_comment :offer_specifications, :specification_id, 'Specification'
    column_comment :offer_specifications, :cost, 'Цена'
    column_comment :offer_specifications, :cost_nds, 'Цена с НДС'
    column_comment :offer_specifications, :final_cost, 'Окончательная цена'
    column_comment :offer_specifications, :final_cost_nds, 'Окончательная цена с НДС'

    create_table "offers", force: true do |t|
      t.integer  "lot_id",    null: false
      t.integer  "bidder_id", null: false
      t.integer  "num",       null: false
      t.integer  "version",   null: false
      t.integer  "type_id",   null: false
      t.integer  "status_id", null: false
      t.integer  "rank"
      t.boolean  "is_winer",                                       default: false
      t.text     "conditions"
      t.text     "note"
      t.text     "change_descriptions"
      t.datetime "created_at",                                                     null: false
      t.datetime "updated_at",                                                     null: false
      t.boolean  "rebidded",                                       default: false, null: false
      t.boolean  "maker",                                          default: false, null: false
      t.boolean  "absent_auction"
      t.text     "final_conditions"
      t.text     "non_contract_reason"
    end

    add_index "offers", ["bidder_id", "lot_id", "num", "version"], name: "i_offers_bidder_lot_num_vers", unique: true

    table_comment :offers, 'Предложения участников'
    column_comment :offers, :non_contract_reason, 'Причины невыполнения 20 дневного срока на заключение договора'
    column_comment :offers, :lot_id, 'Лот'
    column_comment :offers, :bidder_id, 'Участник'
    column_comment :offers, :num, 'Номер'
    column_comment :offers, :version, 'Версия (0 - последняя,актуальная)'
    column_comment :offers, :type_id, 'Статус'
    column_comment :offers, :status_id, 'Статус'
    column_comment :offers, :rank, 'Место в ранжировке'
    column_comment :offers, :is_winer, 'Победитель'
    column_comment :offers, :conditions, 'Существенные условия'
    column_comment :offers, :note, 'Примечания'
    column_comment :offers, :change_descriptions, 'Краткое описание изменений'
    column_comment :offers, :created_at, ''
    column_comment :offers, :updated_at, ''
    column_comment :offers, :rebidded, 'Участник принимал участие в переторжке или аукционе'
    column_comment :offers, :maker, 'Участник является производителем'
    column_comment :offers, :absent_auction, 'Не явился на процедуру аукциона'
    column_comment :offers, :final_conditions, 'Существенные условия после переторжки'

    create_table "okdp", force: true do |t|
      t.integer "parent_id"
      t.string  "code",                                 null: false
      t.string  "name",      limit: 500,                null: false
      t.string  "ancestry"
      t.string  "ref_type"
    end

    add_index "okdp", ["ancestry"], name: "index_okdp_on_ancestry"

    table_comment :okdp, 'Справочник ОКДП'
    column_comment :okdp, :ref_type, 'Тип ОКДП (OKDP or OKPD2)'
    column_comment :okdp, :parent_id, 'ИД родительской записи'
    column_comment :okdp, :code, 'Код справочника'
    column_comment :okdp, :name, 'Наименование'
    column_comment :okdp, :ancestry, 'Служебное поле гема ancestry'

    create_table "okdp_etp", primary_key: "code", force: true do |t|
    end
    change_column :okdp_etp, :code, :string, limit: 255
    table_comment :okdp_etp, 'Коды ОКДП для ЭТП'
    column_comment :okdp_etp, :code, 'код ОКДП'

    create_table :okdp_reform, id: false, comment: 'Соответствия кодов ОКДП и ОКПД2' do |t|
      t.string :old_value, comment: 'Код ОКДП', null: false
      t.string :new_value, comment: 'Код ОКПД2', null: false
    end

    create_table "okved", force: true do |t|
      t.integer "parent_id"
      t.string  "code"
      t.string  "name",      limit: 500
      t.string  "ref_type"
    end

    table_comment :okved, 'Справочник ОКВЕД'
    column_comment :okved, :ref_type, 'Тип ОКВЭД (OKVED or OKVED2)'
    column_comment :okved, :parent_id, 'ИД родительской записи'
    column_comment :okved, :code, 'Код справочника'
    column_comment :okved, :name, 'Наименование'

    create_table :okved_reform, id: false, comment: 'Преобразование кодов ОКВЭД и ОКВЭД2' do |t|
      t.string :old_value, comment: 'Код ОКВЭД', null: false
      t.string :new_value, comment: 'Код ОКВЭД2', null: false
    end

    create_table "open_protocol_present_bidders", force: true do |t|
      t.integer  "open_protocol_id", null: false
      t.integer  "bidder_id", null: false
      t.string   "delegate",                                    null: false
      t.datetime "created_at",                                  null: false
      t.datetime "updated_at",                                  null: false
    end

    add_index "open_protocol_present_bidders", ["open_protocol_id", "bidder_id"], name: "i_protocol_bidder"

    table_comment :open_protocol_present_bidders, 'Присутствовашие на процедуре вскрытия конвертов, представители участников'
    column_comment :open_protocol_present_bidders, :id, ''
    column_comment :open_protocol_present_bidders, :open_protocol_id, 'Ссылка на протокол вскрытия'
    column_comment :open_protocol_present_bidders, :bidder_id, 'Участник'
    column_comment :open_protocol_present_bidders, :delegate, 'ФИО представителя'

    create_table "open_protocol_present_members", force: true do |t|
      t.integer  "open_protocol_id", null: false
      t.integer  "user_id", null: false
      t.integer  "status_id", null: false
      t.datetime "created_at",                                  null: false
      t.datetime "updated_at",                                  null: false
    end

    add_index "open_protocol_present_members", ["open_protocol_id", "user_id", "status_id"], name: "i_oppm_protocol_user_status", unique: true

    table_comment :open_protocol_present_members, 'Лица, присутствовавшие на процедуре вскрытия конвертов'
    column_comment :open_protocol_present_members, :open_protocol_id, 'Ссылка на протокол вскрытия'
    column_comment :open_protocol_present_members, :user_id, 'ФИО'
    column_comment :open_protocol_present_members, :status_id, 'Статус в комиссии'
    column_comment :open_protocol_present_members, :created_at, ''
    column_comment :open_protocol_present_members, :updated_at, ''

    create_table "open_protocols", force: true do |t|
      t.string   "num",                                      null: false
      t.date     "sign_date",                                null: false
      t.string   "sign_city"
      t.datetime "open_date",                                null: false
      t.string   "location"
      t.text     "resolve"
      t.integer  "tender_id", null: false
      t.integer  "clerk_id"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
      t.integer  "commission_id"
    end

    add_index "open_protocols", ["tender_id"], name: "i_open_protocols_tender", unique: true

    table_comment :open_protocols, 'Протоколы вскрытия конвертов'
    column_comment :open_protocols, :num, 'Номер'
    column_comment :open_protocols, :sign_date, 'Дата подписания'
    column_comment :open_protocols, :sign_city, 'Город'
    column_comment :open_protocols, :open_date, 'Дата время'
    column_comment :open_protocols, :location, 'Место'
    column_comment :open_protocols, :resolve, 'Решение'
    column_comment :open_protocols, :tender_id, 'Тендер'
    column_comment :open_protocols, :clerk_id, 'Секретарь ЗК'
    column_comment :open_protocols, :created_at, ''
    column_comment :open_protocols, :updated_at, ''
    column_comment :open_protocols, :commission_id, 'Коммиссия проводившая вскрытие'

    create_table "page_files", force: true do |t|
      t.integer "page_id",  limit: nil, precision: 38
      t.string  "wikifile"
    end

    table_comment :page_files, 'Файлы для wiki'
    column_comment :page_files, :id, ''
    column_comment :page_files, :page_id, 'ИД страницы'
    column_comment :page_files, :wikifile, 'Файл'

    create_table "pages", force: true do |t|
      t.string   "name"
      t.string   "permalink"
      t.text     "content"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "pages", ["permalink"], name: "index_pages_on_permalink"

    table_comment :pages, 'Статические страницы'
    column_comment :pages, :name, 'Заголовок'
    column_comment :pages, :permalink, 'Ссылка'
    column_comment :pages, :content, 'Содержание'

    create_table :plan_annual_limits, comment: 'Годовые лимиты для ПО' do |t|
      t.integer :plan_lot_id, comment: 'Ссылка на планируемый лот', null: false
      t.integer :year, comment: 'Год', null: false
      t.decimal :cost, comment: 'Лимит, руб. без НДС', null: false, precision: 18, scale: 2
      t.decimal :cost_nds, comment: 'Лимит, руб. без НДС', null: false, precision: 18, scale: 2

      t.timestamps null: false
    end

    create_table "plan_lot_contractors", force: true do |t|
      t.integer "plan_lot_id", null: false
      t.integer "contractor_id", null: false
    end

    add_index "plan_lot_contractors", ["plan_lot_id", "contractor_id"], name: "i_planlot_contractor", unique: true

    table_comment :plan_lot_contractors, 'Участники по плану'
    column_comment :plan_lot_contractors, :plan_lot_id, 'Планируемый лот'
    column_comment :plan_lot_contractors, :contractor_id, 'Планируемый участник'

    create_table "plan_lot_non_executions", force: true do |t|
      guid_column t, "plan_lot_guid", null: false
      t.text     "reason"
      t.integer  "user_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "plan_lot_non_executions", ["plan_lot_guid"], name: "i_plne_guid"
    add_index "plan_lot_non_executions", ["user_id"], name: "i_pla_lot_non_exe_use_id"

    table_comment :plan_lot_non_executions, 'Причины неисполнения стартов'
    column_comment :plan_lot_non_executions, :plan_lot_guid, 'План лот гуид'
    column_comment :plan_lot_non_executions, :reason, 'Пичина'
    column_comment :plan_lot_non_executions, :user_id, 'Автор'

    create_table "plan_lots", force: true do |t|
      guid_column t, "guid", null: false
      t.integer  "version",                  default: 0, null: false
      t.integer  "gkpz_year",                null: false
      t.integer  "num_tender",               null: false
      t.integer  "num_lot",                  null: false
      t.string   "lot_name",                 limit: 500, null: false
      t.integer  "department_id"
      t.integer  "tender_type_id"
      t.string   "tender_type_explanations", limit: 4000
      t.integer  "subject_type_id",          null: false
      t.integer  "etp_address_id"
      t.date     "announce_date",            null: false
      t.string   "explanations_doc",         limit: 1000
      t.string   "point_clause"
      t.integer  "protocol_id"
      t.integer  "status_id",                null: false
      t.integer  "commission_id"
      t.integer  "user_id",                  null: false
      t.datetime "created_at",               null: false
      t.datetime "updated_at",               null: false
      t.integer  "root_customer_id",         null: false
      guid_column t, "additional_to"
      t.integer  "state", default: 1, null: false
      t.integer  "sme_type_id"
      t.integer  "additional_num"
      t.integer  "main_direction_id"
      t.integer  "order1352_id"
      guid_column t, "preselection_guid"
      t.integer  "regulation_item_id"
    end
    change_column_null :plan_lots, :tender_type_id, true
    change_column_null :plan_lots, :etp_address_id, true
    change_column_null :plan_lots, :department_id, true

    add_index "plan_lots", ["guid"], name: "i_plan_lots_guid"

    table_comment :plan_lots, 'Планируемые лоты'
    column_comment :plan_lots, :order1352_id, 'Типы закупок из постановления правительства №1352 от 11.12.2014'
    column_comment :plan_lots, :preselection_guid, 'GUID закупки предварительного отбора'
    column_comment :plan_lots, :guid, 'ГУИД лота'
    column_comment :plan_lots, :version, 'Версия записи (0 - текущая)'
    column_comment :plan_lots, :gkpz_year, 'Год ГКПЗ'
    column_comment :plan_lots, :num_tender, 'Номер закупки'
    column_comment :plan_lots, :num_lot, 'Номер лота'
    column_comment :plan_lots, :lot_name, 'Наименование лота'
    column_comment :plan_lots, :department_id, 'ИД организатора'
    column_comment :plan_lots, :tender_type_id, 'ИД способа закупки'
    column_comment :plan_lots, :tender_type_explanations, 'Обоснование выбора способа закупки'
    column_comment :plan_lots, :subject_type_id, 'Предмет закупки'
    column_comment :plan_lots, :etp_address_id, 'ИД адреса ЭТП, на которой будет объявлена закупка'
    column_comment :plan_lots, :announce_date, 'Дата объявления'
    column_comment :plan_lots, :explanations_doc, 'Обосновывающий док-т (только для ЕИ)'
    column_comment :plan_lots, :point_clause, 'Пункт положения'
    column_comment :plan_lots, :protocol_id, 'ИД протокола'
    column_comment :plan_lots, :status_id, 'ИД статуса'
    column_comment :plan_lots, :commission_id, 'ИД комиссии'
    column_comment :plan_lots, :user_id, 'ИД пользователя'
    column_comment :plan_lots, :root_customer_id, 'ИД рутового заказчика'
    column_comment :plan_lots, :additional_to, 'ГУИД основной закупки'
    column_comment :plan_lots, :state, 'Состояние в ГКПЗ: 0 - внеплан, 1 - план'
    column_comment :plan_lots, :sme_type_id, 'Отношение к участию субъектов малого и среднего предпринимательства'
    column_comment :plan_lots, :additional_num, 'Номер доп. соглашения'
    column_comment :plan_lots, :main_direction_id, 'Главное направление'
    column_comment :plan_lots, :regulation_item_id, 'Ссылка на пункт положения'

    create_table "plan_lots_files", force: true do |t|
      t.integer "plan_lot_id", null: false
      t.integer "tender_file_id", null: false
      t.text    "note"
      t.integer "file_type_id", null: false
    end

    add_index "plan_lots_files", ["plan_lot_id", "tender_file_id"], name: "i7408c718c6c9017b2c9d250f1d1ad", unique: true

    table_comment :plan_lots_files, 'Привязка файлов к план. лотам'
    column_comment :plan_lots_files, :plan_lot_id, 'ИД план. лота'
    column_comment :plan_lots_files, :tender_file_id, 'ИД файла'
    column_comment :plan_lots_files, :note, 'Комментарий к файлу'
    column_comment :plan_lots_files, :file_type_id, 'Тип файла (в dictionaries)'

    create_table "plan_spec_amounts", force: true do |t|
      t.integer "plan_specification_id",           null: false
      t.integer "year", null: false
      t.decimal "amount_mastery",                    precision: 18, scale: 2
      t.decimal "amount_mastery_nds",                precision: 18, scale: 2
      t.decimal "amount_finance",                    precision: 18, scale: 2
      t.decimal "amount_finance_nds",                precision: 18, scale: 2
    end

    table_comment :plan_spec_amounts, 'Планируемые суммы спецификаций'
    column_comment :plan_spec_amounts, :plan_specification_id, 'ИД спецификации'
    column_comment :plan_spec_amounts, :year, 'Год'
    column_comment :plan_spec_amounts, :amount_mastery, 'Освоение без НДС'
    column_comment :plan_spec_amounts, :amount_mastery_nds, 'Освоение с НДС'
    column_comment :plan_spec_amounts, :amount_finance, 'Финансирование без НДС'
    column_comment :plan_spec_amounts, :amount_finance_nds, 'Финансирование с НДС'

    create_table "plan_specifications", force: true do |t|
      t.integer  "plan_lot_id",            null: false
      guid_column t, "guid", null: false
      t.integer  "num_spec",               null: false
      t.string   "name",                   limit: 500,                           null: false
      t.integer  "qty",                    null: false
      t.decimal  "cost",                                precision: 18, scale: 2, null: false
      t.decimal  "cost_nds",                            precision: 18, scale: 2, null: false
      t.string   "cost_doc"
      t.integer  "unit_id"
      t.integer  "okdp_id"
      t.integer  "okved_id"
      t.integer  "direction_id",           null: false
      t.integer  "product_type_id"
      t.integer  "financing_id"
      t.integer  "customer_id",           null: false
      t.integer  "consumer_id",           null: false
      t.integer  "monitor_service_id"
      t.integer  "invest_project_id"
      t.date     "delivery_date_begin",                                          null: false
      t.date     "delivery_date_end",                                            null: false
      t.string   "bp_item",                limit: 1000
      t.string   "requirements"
      t.string   "potential_participants", limit: 4000
      t.string   "curator"
      t.string   "tech_curator"
      t.text     "note"
      t.datetime "created_at",                                                   null: false
      t.datetime "updated_at",                                                   null: false
    end

    add_index "plan_specifications", ["guid"], name: "i_plan_specs_guid"
    add_index "plan_specifications", ["plan_lot_id"], name: "i_pla_spe_pla_lot_id"

    table_comment :plan_specifications, 'Спецификации лотов'
    column_comment :plan_specifications, :plan_lot_id, 'ИД лота'
    column_comment :plan_specifications, :guid, 'ГУИД спецификации'
    column_comment :plan_specifications, :num_spec, '№ спец.'
    column_comment :plan_specifications, :name, 'Наименование спецификации'
    column_comment :plan_specifications, :qty, 'Кол-во'
    column_comment :plan_specifications, :cost, 'Цена, руб. без НДС'
    column_comment :plan_specifications, :cost_nds, 'Цена, руб. с НДС'
    column_comment :plan_specifications, :cost_doc, 'Документ определяющий цену'
    column_comment :plan_specifications, :unit_id, 'ИД ед. измерения (ОКЕИ)'
    column_comment :plan_specifications, :okdp_id, 'ИД ОКДП'
    column_comment :plan_specifications, :okved_id, 'ИД ОКВЭД'
    column_comment :plan_specifications, :direction_id, 'ИД направления закупки'
    column_comment :plan_specifications, :product_type_id, 'ИД вида продукции'
    column_comment :plan_specifications, :financing_id, 'ИД источника финансирования'
    column_comment :plan_specifications, :customer_id, 'ИД заказчика'
    column_comment :plan_specifications, :consumer_id, 'ИД потребителя'
    column_comment :plan_specifications, :monitor_service_id, 'ИД курирующего подразделения'
    column_comment :plan_specifications, :invest_project_id, 'ИД инвест. проекта'
    column_comment :plan_specifications, :delivery_date_begin, 'Начало поставки'
    column_comment :plan_specifications, :delivery_date_end, 'Окончание поставки'
    column_comment :plan_specifications, :bp_item, 'Номер пункта ФБ / Строка бизнес-плана'
    column_comment :plan_specifications, :requirements, 'Минимально необходимые требования к закупаемой продукции'
    column_comment :plan_specifications, :potential_participants, 'Потенциальные участники'
    column_comment :plan_specifications, :curator, 'Куратор'
    column_comment :plan_specifications, :tech_curator, 'Технический куратор'
    column_comment :plan_specifications, :note, 'Примечания'

    create_table :protocol_files do |t|
      t.integer :protocol_id, comment: 'Протокол', null: false
      t.integer :tender_file_id, comment: 'Файл', null: false
      t.text :note, comment: 'Примечания'

      t.timestamps null: false
    end

    create_table "protocol_users", force: true do |t|
      t.integer  "commission_id"
      t.integer  "user_id"
      t.integer  "status"
      t.boolean  "is_veto"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end

    create_table "protocols", force: true do |t|
      t.string   "num",                                      null: false
      t.date     "date_confirm",                             null: false
      t.string   "location"
      t.integer  "format_id", null: false
      t.integer  "commission_id", null: false
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
      t.integer  "gkpz_year", null: false
    end

    table_comment :protocols, 'Протоколы'
    column_comment :protocols, :num, 'Номер протокола'
    column_comment :protocols, :date_confirm, 'Дата протокола'
    column_comment :protocols, :location, 'Место проведения'
    column_comment :protocols, :format_id, 'Форма проведения'
    column_comment :protocols, :commission_id, 'Закупочный орган'
    column_comment :protocols, :gkpz_year, 'Год ГКПЗ'

    create_table "rebid_protocol_present_bidders", force: true do |t|
      t.integer  "rebid_protocol_id", null: false
      t.integer  "bidder_id", null: false
      t.string   "delegate",                                     null: false
      t.datetime "created_at",                                   null: false
      t.datetime "updated_at",                                   null: false
    end

    add_index "rebid_protocol_present_bidders", ["rebid_protocol_id"], name: "i_reb_pro_pre_bid_reb_pro_id"

    table_comment :rebid_protocol_present_bidders, 'Присутствовавшие участники на переторжке'
    column_comment :rebid_protocol_present_bidders, :rebid_protocol_id, 'Протокол переторжки'
    column_comment :rebid_protocol_present_bidders, :bidder_id, 'Участник'
    column_comment :rebid_protocol_present_bidders, :delegate, 'ФИО представителя'

    create_table "rebid_protocol_present_members", force: true do |t|
      t.integer  "rebid_protocol_id", precision: 38
      t.integer  "user_id",           limit: nil, precision: 38
      t.integer  "status_id",         limit: nil, precision: 38
      t.datetime "created_at",                                   null: false
      t.datetime "updated_at",                                   null: false
    end

    add_index "rebid_protocol_present_members", ["rebid_protocol_id"], name: "i_reb_pro_pre_mem_reb_pro_id"

    table_comment :rebid_protocol_present_members, 'Пристуствовавшие члены коммиссиии на переторжке'
    column_comment :rebid_protocol_present_members, :id, ''
    column_comment :rebid_protocol_present_members, :rebid_protocol_id, 'Протокол переторжки'
    column_comment :rebid_protocol_present_members, :user_id, 'Член коммиссии, пользователь системы'
    column_comment :rebid_protocol_present_members, :status_id, 'Статус его в коммиссии'

    create_table "rebid_protocols", force: true do |t|
      t.integer  "tender_id", null: false
      t.string   "num",                                      null: false
      t.date     "confirm_date",                             null: false
      t.date     "vote_date"
      t.string   "confirm_city",                             null: false
      t.datetime "rebid_date",                               null: false
      t.string   "location",                                 null: false
      t.text     "resolve",                                  null: false
      t.integer  "clerk_id", null: false
      t.integer  "commission_id", null: false
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end

    add_index "rebid_protocols", ["tender_id"], name: "i_rebid_protocols_tender_id"

    table_comment :rebid_protocols, 'Протоколы переторжки'
    column_comment :rebid_protocols, :tender_id, 'Тендер'
    column_comment :rebid_protocols, :num, 'Номер протокола'
    column_comment :rebid_protocols, :confirm_date, 'Дата протокола'
    column_comment :rebid_protocols, :vote_date, 'Дата подписания'
    column_comment :rebid_protocols, :confirm_city, 'Место утверждения протокола'
    column_comment :rebid_protocols, :rebid_date, 'Дата и время проведения переторжки'
    column_comment :rebid_protocols, :location, 'Место проведения переторжки'
    column_comment :rebid_protocols, :resolve, 'Решение'
    column_comment :rebid_protocols, :clerk_id, 'Секретарь ЗК'
    column_comment :rebid_protocols, :commission_id, 'Закупочная коммиссия'

    create_table :regulation_items, comment: 'Справочник пунктов положения о закупке' do |t|
      t.string :num, comment: 'Номер пункта', null: false
      t.text :name, comment: 'Наименование'
      t.boolean :is_actual, comment: 'Действующий?'

      t.timestamps null: false
    end

    create_table :reg_item_tender_types, comment: 'Join table regulation_items and tender_types' do |t|
      t.integer :item_id, comment: 'Ссылка на пункт положения', null: false
      t.integer :tender_type_id, comment: 'Ссылка на способ закупки', null: false
    end

    create_table "result_protocol_lots", force: true do |t|
      t.integer "result_protocol_id", null: false
      t.integer "lot_id", null: false
    end

    add_index "result_protocol_lots", ["lot_id"], name: "i_result_protocol_lots_lot_id"
    add_index "result_protocol_lots", ["result_protocol_id"], name: "i_res_pro_lot_res_pro_id"

    table_comment :result_protocol_lots, 'Join Table ResultProtocol to Lot'
    column_comment :result_protocol_lots, :result_protocol_id, 'Протокол о результатах'
    column_comment :result_protocol_lots, :lot_id, 'Лот'

    create_table "result_protocols", force: true do |t|
      t.integer  "tender_id", null: false
      t.string   "num",                                   null: false
      t.date     "sign_date",                             null: false
      t.string   "sign_city",                             null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "result_protocols", ["tender_id"], name: "i_result_protocols_tender_id"

    table_comment :result_protocols, 'Протоколы о результатах'
    column_comment :result_protocols, :tender_id, 'ИД тендера'
    column_comment :result_protocols, :num, 'Номер'
    column_comment :result_protocols, :sign_date, 'Дата подписания'
    column_comment :result_protocols, :sign_city, 'Город'

    create_table "review_lots", force: true do |t|
      t.integer  "lot_id", null: false
      t.integer  "review_protocol_id", null: false
      t.datetime "rebid_date"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "rebid_place"
    end

    add_index "review_lots", ["review_protocol_id"], name: "i_rev_lot_rev_pro_id"

    table_comment :review_lots, 'Связующая таблица для лотов и протоколов рассмотрения'
    column_comment :review_lots, :lot_id, 'Лот'
    column_comment :review_lots, :review_protocol_id, 'Протокол рассмотрения'
    column_comment :review_lots, :rebid_date, 'Дата вскрытия с переторжкой'
    column_comment :review_lots, :rebid_place, 'Место проведения переторжки'

    create_table "review_protocols", force: true do |t|
      t.integer  "tender_id", null: false
      t.string   "num",                                     null: false
      t.date     "confirm_date",                            null: false
      t.date     "vote_date"
      t.datetime "created_at",                              null: false
      t.datetime "updated_at",                              null: false
    end

    add_index "review_protocols", ["tender_id"], name: "i_review_protocols_tender_id"

    table_comment :review_protocols, 'Протоколы рассмотрения'
    column_comment :review_protocols, :tender_id, 'ИД тендера'
    column_comment :review_protocols, :num, 'Номер'
    column_comment :review_protocols, :confirm_date, 'Дата вступления в силу'
    column_comment :review_protocols, :vote_date, 'Дата голосования'

    create_table "roles", force: true do |t|
      t.string   "name",                                              null: false
      t.string   "name_ru",                                           null: false
      t.datetime "created_at",                                        null: false
      t.datetime "updated_at",                                        null: false
      t.integer  "position", default: 1, null: false
    end

    table_comment :roles, 'Роли пользователей'
    column_comment :roles, :name, 'Наименование (англ)'
    column_comment :roles, :name_ru, 'Наименование (рус)'
    column_comment :roles, :position, 'Порядок загрузки ролей'

    create_table "specifications", force: true do |t|
      t.integer  "num",                   null: false
      t.string   "name",                  limit: 500,                          null: false
      t.integer  "qty",                   null: false
      t.decimal  "cost",                              precision: 18, scale: 2, null: false
      t.decimal  "cost_nds",                          precision: 18, scale: 2, null: false
      t.boolean  "is_public_cost"
      t.integer  "unit_id",               null: false
      t.integer  "lot_id",                null: false
      t.integer  "plan_specification_id"
      t.integer  "direction_id",          null: false
      t.integer  "financing_id",          null: false
      t.integer  "product_type_id",       null: false
      t.integer  "customer_id",           null: false
      t.integer  "consumer_id",           null: false
      t.integer  "invest_project_id"
      t.integer  "monitor_service_id"
      t.datetime "created_at",                                                 null: false
      t.datetime "updated_at",                                                 null: false
      t.date     "delivery_date_begin"
      t.date     "delivery_date_end"
      t.integer  "contact_id"
      t.integer  "frame_id"
      guid_column t, "guid"
    end

    add_index "specifications", ["lot_id"], name: "i_specifications_lot"

    table_comment :specifications, 'Спецификация'
    column_comment :specifications, :num, 'Номер'
    column_comment :specifications, :name, 'Наименование'
    column_comment :specifications, :qty, 'Кол-во'
    column_comment :specifications, :cost, 'Цена без НДС'
    column_comment :specifications, :cost_nds, 'Цена с НДС'
    column_comment :specifications, :is_public_cost, 'Цена опубликована'
    column_comment :specifications, :unit_id, 'Код ОКЕИ'
    column_comment :specifications, :lot_id, 'Ссылка на лот'
    column_comment :specifications, :plan_specification_id, 'Ссылка на спецификацию в планировании'
    column_comment :specifications, :direction_id, 'Направление закупки'
    column_comment :specifications, :financing_id, 'Источник финансирования'
    column_comment :specifications, :product_type_id, 'Вид закупаемой продукции'
    column_comment :specifications, :customer_id, 'Заказчик'
    column_comment :specifications, :consumer_id, 'Потребитель'
    column_comment :specifications, :invest_project_id, 'Инвестиционный проект'
    column_comment :specifications, :monitor_service_id, 'Курирующее подразделение'
    column_comment :specifications, :delivery_date_begin, 'Дата начала поставки'
    column_comment :specifications, :delivery_date_end, 'Дата окончания поставки'
    column_comment :specifications, :contact_id, 'Контакты заказчика'
    column_comment :specifications, :frame_id, 'Спецификация рамки'
    column_comment :specifications, :guid, 'Глабальный идентификатор'

    create_table "sub_contractor_specs", force: true do |t|
      t.integer  "specification_id",          null: false
      t.integer  "contract_specification_id", null: false
      t.integer  "sub_contractor_id",         null: false
      t.decimal  "cost",                                  precision: 18, scale: 2
      t.decimal  "cost_nds",                              precision: 18, scale: 2
      t.datetime "created_at",                                                     null: false
      t.datetime "updated_at",                                                     null: false
    end

    table_comment :sub_contractor_specs, 'Доли субподрядчиков по спецификациям'
    column_comment :sub_contractor_specs, :specification_id, 'ИД спецификации'
    column_comment :sub_contractor_specs, :contract_specification_id, 'ИД спецификации договора'
    column_comment :sub_contractor_specs, :sub_contractor_id, 'ИД субподрядчика'
    column_comment :sub_contractor_specs, :cost, 'Цена без НДС'
    column_comment :sub_contractor_specs, :cost_nds, 'Цена с НДС'

    create_table "sub_contractors", force: true do |t|
      t.integer  "contract_id", null: false
      t.integer  "contractor_id", null: false
      t.string   "name"
      t.date     "confirm_date"
      t.string   "num"
      t.date     "begin_date"
      t.date     "end_date"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end

    table_comment :sub_contractors, 'Субподрядчики'
    column_comment :sub_contractors, :contract_id, 'ИД договора'
    column_comment :sub_contractors, :contractor_id, 'ИД контрагента'
    column_comment :sub_contractors, :name, 'Предмет договора с субподрядчиком'
    column_comment :sub_contractors, :confirm_date, 'Дата заключения договора'
    column_comment :sub_contractors, :num, 'Номер договора'
    column_comment :sub_contractors, :begin_date, 'Дата начала исполнения'
    column_comment :sub_contractors, :end_date, 'Дата окончания исполнения'

    create_table "subscribe_actions", force: true do |t|
      t.integer "subscribe_id", null: false
      t.integer "action_id", null: false
      t.integer "days_before"
    end

    add_index "subscribe_actions", ["subscribe_id"], name: "i_subscribe_actions"

    table_comment :subscribe_actions, 'События для подписки'
    column_comment :subscribe_actions, :subscribe_id, 'ИД подписки'
    column_comment :subscribe_actions, :action_id, 'ИД события'
    column_comment :subscribe_actions, :days_before, 'Предупреждать за ... дней'

    create_table "subscribe_notifications", force: true do |t|
      t.integer  "user_id", null: false
      t.text     "format_html",                             null: false
      t.text     "format_email"
      t.datetime "created_at",                              null: false
      t.datetime "updated_at",                              null: false
    end

    add_index "subscribe_notifications", ["user_id"], name: "i_subscribe_notifies_user"

    table_comment :subscribe_notifications, 'Таблица с сообщениями для пользователей'
    column_comment :subscribe_notifications, :user_id, 'ИД пользователя'
    column_comment :subscribe_notifications, :format_html, 'Сообщение в формате HTML'
    column_comment :subscribe_notifications, :format_email, 'Сообщение в формате EMAIL'

    create_table "subscribes", force: true do |t|
      t.integer  "user_id", null: false
      guid_column t, "plan_lot_guid", null: false
      t.text     "plan_structure",                            null: false
      t.text     "fact_structure"
      t.datetime "created_at",                                null: false
      t.datetime "updated_at",                                null: false
      t.string   "theme"
    end

    add_index "subscribes", ["user_id"], name: "i_subscribes_user"

    table_comment :subscribes, 'Подписки'
    column_comment :subscribes, :user_id, 'ИД пользователя'
    column_comment :subscribes, :plan_lot_guid, 'ГУИД лота'
    column_comment :subscribes, :plan_structure, 'Структура лота в плане'
    column_comment :subscribes, :fact_structure, 'Структура лота в факте'
    column_comment :subscribes, :theme, 'Тема подписки'

    create_table "task_statuses", force: true do |t|
      t.string "name"
    end

    table_comment :task_statuses, 'Статусы задач'
    column_comment :task_statuses, :name, 'Наименование'

    create_table "tasks", force: true do |t|
      t.text     "description"
      t.integer  "priority"
      t.integer  "task_status_id", null: false
      t.text     "task_comment"
      t.integer  "user_id", null: false
      t.datetime "created_at",                                null: false
      t.datetime "updated_at",                                null: false
    end

    table_comment :tasks, 'Задачи которые нужно выполнить'
    column_comment :tasks, :description, 'Описание'
    column_comment :tasks, :priority, 'Приоритет'
    column_comment :tasks, :task_status_id, 'ИД статуса'
    column_comment :tasks, :task_comment, 'Комментарий'
    column_comment :tasks, :user_id, 'ИД пользователя'

    create_table "tender_content_offers", force: true do |t|
      t.text    "name",                                                           null: false
      t.string  "num",                                                            null: false
      t.integer "position", default: 100, null: false
      t.integer "content_offer_type_id",               null: false
      t.integer "tender_id",               null: false
    end

    add_index "tender_content_offers", ["tender_id"], name: "i_ten_con_off_ten_id"

    table_comment :tender_content_offers, 'Требования к составу заявок'
    column_comment :tender_content_offers, :name, 'Наименование'
    column_comment :tender_content_offers, :num, 'Номер'
    column_comment :tender_content_offers, :position, 'Порядок сортировки'
    column_comment :tender_content_offers, :content_offer_type_id, 'Тип требования'
    column_comment :tender_content_offers, :tender_id, 'Тендер'

    create_table "tender_draft_criterions", force: true do |t|
      t.integer "num", null: false
      t.text    "name",                                 null: false
      t.integer "tender_id", null: false
    end

    table_comment :tender_draft_criterions, 'Отборочные критерии'
    column_comment :tender_draft_criterions, :num, 'Номер'
    column_comment :tender_draft_criterions, :name, 'Наименование'
    column_comment :tender_draft_criterions, :tender_id, 'Тендер'

    create_table "tender_eval_criterions", force: true do |t|
      t.string  "num",                                                null: false
      t.integer "position", default: 100, null: false
      t.text    "name",                                               null: false
      t.integer "value",               null: false
      t.integer "tender_id",               null: false
    end

    table_comment :tender_eval_criterions, 'Оценочные критерии'
    column_comment :tender_eval_criterions, :num, 'Номер'
    column_comment :tender_eval_criterions, :position, 'Порядок сортировки'
    column_comment :tender_eval_criterions, :name, 'Наименование'
    column_comment :tender_eval_criterions, :value, 'Вес'
    column_comment :tender_eval_criterions, :tender_id, 'Тендер'

    create_table "tender_files", force: true do |t|
      t.integer  "area_id", null: false
      t.integer  "year", null: false
      t.string   "document",                                     null: false
      t.integer  "user_id", null: false
      t.string   "external_filename"
      t.string   "content_type",                                 null: false
      t.integer  "file_size", null: false
      t.datetime "created_at",                                   null: false
    end

    table_comment :tender_files, 'Прикреплённые файлы'
    column_comment :tender_files, :area_id, 'Область использования (расшифровка в константах)'
    column_comment :tender_files, :year, 'Год привязки'
    column_comment :tender_files, :document, 'Имя файла документа'
    column_comment :tender_files, :user_id, 'Пользователь владелец'
    column_comment :tender_files, :external_filename, 'Имя файла во внешинх системах'
    column_comment :tender_files, :content_type, 'Content Type'
    column_comment :tender_files, :file_size, 'Размер'
    column_comment :tender_files, :created_at, 'Дата создания'

    create_table "tender_requests", force: true do |t|
      t.integer  "tender_id", null: false
      t.integer  "contractor_id"
      t.date     "register_date",                              null: false
      t.string   "inbox_num",       limit: 30,                 null: false
      t.date     "inbox_date",                                 null: false
      t.text     "request"
      t.integer  "user_id"
      t.string   "outbox_num",      limit: 30
      t.date     "outbox_date"
      t.datetime "created_at",                                 null: false
      t.datetime "updated_at",                                 null: false
      t.string   "contractor_text"
    end

    add_index "tender_requests", ["tender_id"], name: "i_tender_requests_tender"

    table_comment :tender_requests, 'Запрос на разъяснение'
    column_comment :tender_requests, :contractor_text, 'Наименование контрагента'
    column_comment :tender_requests, :tender_id, 'Tender'
    column_comment :tender_requests, :contractor_id, 'Контрагент'
    column_comment :tender_requests, :register_date, 'Дата получения запроса'
    column_comment :tender_requests, :inbox_num, 'Номер исх. письма'
    column_comment :tender_requests, :inbox_date, 'Дата исх. письма'
    column_comment :tender_requests, :request, 'Краткая характеристика запроса на разъяснение'
    column_comment :tender_requests, :user_id, 'Пользователь, подготовивший ответ'
    column_comment :tender_requests, :outbox_num, 'Номер ответного письма'
    column_comment :tender_requests, :outbox_date, 'Дата ответного письма'

    create_table "tender_type_rules", id: false, force: true do |t|
      t.integer "plan_type_id", precision: 38, null: false
      t.integer "fact_type_id", precision: 38, null: false
    end

    table_comment :tender_type_rules, 'Правила смены способов закупок'
    column_comment :tender_type_rules, :plan_type_id, 'Планируемый сопсоб'
    column_comment :tender_type_rules, :fact_type_id, 'Фактический способ'

    create_table "tenders", force: true do |t|
      t.string   "num",                      limit: 70,                           null: false
      t.string   "name",                     limit: 500
      t.integer  "tender_type_id",           null: false
      t.text     "tender_type_explanations"
      t.integer  "etp_address_id",           null: false
      t.integer  "commission_id"
      t.integer  "department_id",            null: false
      t.date     "announce_date",                                                 null: false
      t.string   "announce_place"
      t.datetime "bid_date",                                                      null: false
      t.string   "bid_place"
      t.integer  "user_id"
      t.integer  "oos_num"
      t.integer  "oos_id"
      t.integer  "etp_num"
      t.string   "order_num",                limit: 70
      t.date     "order_date"
      t.integer  "contact_id"
      t.string   "confirm_place"
      t.integer  "explanation_period"
      t.integer  "paper_copies"
      t.integer  "digit_copies"
      t.integer  "life_offer"
      t.date     "offer_reception_start"
      t.date     "offer_reception_stop"
      t.string   "review_place"
      t.datetime "review_date"
      t.string   "summary_place"
      t.datetime "summary_date"
      t.boolean  "is_sertification"
      t.boolean  "is_guarantie"
      t.text     "guarantie_offer"
      t.date     "guarantie_date_begin"
      t.date     "guarantie_date_end"
      t.text     "guarantie_making_money"
      t.text     "guarantie_recvisits"
      t.text     "guarant_criterions"
      t.boolean  "is_multipart"
      t.integer  "alternate_offer"
      t.text     "alternate_offer_aspects"
      t.text     "maturity"
      t.boolean  "is_prepayment"
      t.decimal  "prepayment_cost",                      precision: 18, scale: 2
      t.decimal  "prepayment_percent",                   precision: 18, scale: 2
      t.text     "prepayment_aspects"
      t.text     "prepayment_period_begin"
      t.text     "prepayment_period_end"
      t.integer  "project_type_id"
      t.text     "project_text"
      t.text     "provide_td"
      t.text     "preferences"
      t.text     "other_terms"
      t.integer  "contract_period"
      t.text     "prepare_offer"
      t.text     "provide_offer"
      t.boolean  "is_gencontractor"
      t.text     "contract_guarantie"
      t.boolean  "is_simple_production"
      t.text     "reason_for_replace"
      t.boolean  "is_rebid"
      t.datetime "created_at",                                                    null: false
      t.datetime "updated_at",                                                    null: false
      t.integer  "failure_period"
      t.string   "offer_reception_place"
      t.integer  "local_time_zone_id"
      t.boolean  "is_profitable"
      t.boolean  "contract_period_type"
    end

    table_comment :tenders, 'Тендер'
    column_comment :tenders, :num, 'Номер'
    column_comment :tenders, :name, 'Наименование'
    column_comment :tenders, :tender_type_id, 'Способ закупки'
    column_comment :tenders, :tender_type_explanations, 'Обоснование выбора способа'
    column_comment :tenders, :etp_address_id, 'Адрес ЭТП'
    column_comment :tenders, :commission_id, 'Закупочная комиссия'
    column_comment :tenders, :department_id, 'Организатор'
    column_comment :tenders, :announce_date, 'Дата публикации в СМИ'
    column_comment :tenders, :announce_place, 'Место публикации'
    column_comment :tenders, :bid_date, 'Дата вскрытия конвертов'
    column_comment :tenders, :bid_place, 'Место вскрытия конвертов'
    column_comment :tenders, :user_id, 'Ответственный пользователь'
    column_comment :tenders, :oos_num, 'Номер закупки на ООС'
    column_comment :tenders, :oos_id, 'Идентификатор закупки на ООС'
    column_comment :tenders, :etp_num, 'Номер закупки на ЭТП'
    column_comment :tenders, :order_num, '№ распоряжения'
    column_comment :tenders, :order_date, 'Дата распоряжения'
    column_comment :tenders, :contact_id, 'Контактные данные организатора'
    column_comment :tenders, :confirm_place, 'Место утверждения документации'
    column_comment :tenders, :explanation_period, 'Срок предоставления запросов на разъяснение (дней до вскрытия)'
    column_comment :tenders, :paper_copies, 'Количество копий заявок/предложений на бумажном носителе'
    column_comment :tenders, :digit_copies, 'Количество копий заявок/предложений в электронном виде'
    column_comment :tenders, :life_offer, 'Срок действия конкурсной заявки'
    column_comment :tenders, :offer_reception_start, 'Дата начала приёма заявок/предложений'
    column_comment :tenders, :offer_reception_stop, 'Дата окончания приёма заявок/предложений'
    column_comment :tenders, :review_place, 'Место рассмотрения заявок/предложений'
    column_comment :tenders, :review_date, 'Дата рассмотрения заявок/предложений'
    column_comment :tenders, :summary_place, 'Место подведения итогов'
    column_comment :tenders, :summary_date, 'Дата подведения итогов'
    column_comment :tenders, :is_sertification, 'Учитывается/не учитывается добровольная сертификация'
    column_comment :tenders, :is_guarantie, 'Требуется/не требуется обеспечение заявок'
    column_comment :tenders, :guarantie_offer, 'Форма обеспечения заявок'
    column_comment :tenders, :guarantie_date_begin, 'Срок обеспечения (дата начала)'
    column_comment :tenders, :guarantie_date_end, 'Срок обеспечения (дата окончания)'
    column_comment :tenders, :guarantie_making_money, 'Порядок внечения денежных средств'
    column_comment :tenders, :guarantie_recvisits, 'Реквизиты для перечисления'
    column_comment :tenders, :guarant_criterions, 'Требования к гаранту'
    column_comment :tenders, :is_multipart, 'Допускаются/не допускаются коллективные участники'
    column_comment :tenders, :alternate_offer, 'Количество альтернативных предложений'
    column_comment :tenders, :alternate_offer_aspects, 'Аспекты по которым может быть подано альтернативное предложение'
    column_comment :tenders, :maturity, 'Срок оплаты'
    column_comment :tenders, :is_prepayment, 'Допускается/не допускается авансирование'
    column_comment :tenders, :prepayment_cost, 'Размер аванса руб'
    column_comment :tenders, :prepayment_percent, 'Размер аванса %'
    column_comment :tenders, :prepayment_aspects, 'Условия аванса'
    column_comment :tenders, :prepayment_period_begin, 'Срок оплаты аванса'
    column_comment :tenders, :prepayment_period_end, 'Срок оплаты оставшейся части'
    column_comment :tenders, :project_type_id, 'Вид проекта договора'
    column_comment :tenders, :project_text, 'Текст проекта договора'
    column_comment :tenders, :provide_td, 'Порядок предоставления документации'
    column_comment :tenders, :preferences, 'Преференции'
    column_comment :tenders, :other_terms, 'Иные существенные условия'
    column_comment :tenders, :contract_period, 'Срок заключения договора'
    column_comment :tenders, :prepare_offer, 'Порядок подготовки заявок/предложений'
    column_comment :tenders, :provide_offer, 'Порядок предоставления заявок/предложений'
    column_comment :tenders, :is_gencontractor, 'Право участвовать генеральным подрядчикам'
    column_comment :tenders, :contract_guarantie, 'Обеспечение исполнения обязательств по договору'
    column_comment :tenders, :is_simple_production, 'Простая продукция'
    column_comment :tenders, :reason_for_replace, 'Причины внесения изменений'
    column_comment :tenders, :is_rebid, 'Переторжка предусмотрена/не предусмотрена'
    column_comment :tenders, :failure_period, 'Срок отказа от проведения конкурса'
    column_comment :tenders, :offer_reception_place, 'Место предоставления конвертов'
    column_comment :tenders, :local_time_zone_id, 'Часовой пояс проведения закупки'
    column_comment :tenders, :is_profitable, 'Закупка в счет доходных договоров'
    column_comment :tenders, :contract_period_type, '0 - календарные дни, 1 - рабочие'

    create_table :unfair_contractors, comment: 'Реест недобросовестных контрагентов' do |t|
      t.integer :num,           comment: 'Номер реестровой записи',     null:false
      t.date :date_in,          comment: 'Дата включения в реестр',     null:false
      t.integer :contractor_id, comment: 'ИД контрагента',              null:false
      guid_column t,                    "contractor_guid",             null:false
      t.text :contract_info,    comment: 'Сведения о договоре',         null:false
      t.text :unfair_info,      comment: 'Сведения о нарушении',        null:false
      t.date :date_out,         comment: 'Дата исключения из реестра'
      t.text :note,             comment: 'Примечание'

      t.timestamps null: false
    end

    create_join_table :lots, :unfair_contractors, comment: 'Таблица для связи таблицы unfair_contractors и lots' do |t|
      t.index :lot_id
      t.index :unfair_contractor_id
    end

    create_table "unit_subtitles", force: true do |t|
      t.string   "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    table_comment :unit_subtitles, 'Подразделы справочника ОКЕИ'
    column_comment :unit_subtitles, :name, 'Наименование'

    create_table "unit_titles", force: true do |t|
      t.string   "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    table_comment :unit_titles, 'Разделы справочника ОКЕИ'
    column_comment :unit_titles, :name, 'Наименование'

    create_table "units", force: true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "symbol_n"
      t.string   "symbol_i"
      t.string   "letter_n"
      t.string   "letter_i"
      t.integer  "unit_title_id"
      t.integer  "unit_subtitle_id"
      t.string   "symbol_name",                                 null: false
      t.datetime "created_at",                                  null: false
      t.datetime "updated_at",                                  null: false
    end

    table_comment :units, 'Справочник ОКЕИ'
    column_comment :units, :code, 'Код справочника'
    column_comment :units, :name, 'Наименование'
    column_comment :units, :symbol_n, 'Сокр. нац. симв.'
    column_comment :units, :symbol_i, 'Сокр. интернац. симв.'
    column_comment :units, :letter_n, 'Сокр. нац. письм.'
    column_comment :units, :letter_i, 'Сокр. интернац. письм.'
    column_comment :units, :unit_title_id, 'ИД раздела'
    column_comment :units, :unit_subtitle_id, 'ИД подраздела'
    column_comment :units, :symbol_name, 'Симв. наименование'

    create_table "user_configs", force: true do |t|
      t.integer  "user_id", null: false
      t.string   "subscribe_send_time"
      t.datetime "created_at",                                     null: false
      t.datetime "updated_at",                                     null: false
    end

    add_index "user_configs", ["user_id"], name: "i_user_configs", unique: true

    table_comment :user_configs, 'Личные настройки пользователя'
    column_comment :user_configs, :user_id, 'ИД пользователя'
    column_comment :user_configs, :subscribe_send_time, 'Ежедневное время доставки уведомлений по подпискам'

    create_table "users", force: true do |t|
      t.string   "email",                                             default: "",    null: false
      t.string   "surname",                limit: 50,                                 null: false
      t.string   "name",                   limit: 50,                                 null: false
      t.string   "patronymic",             limit: 50,                                 null: false
      t.string   "user_job"
      t.string   "phone_public",           limit: 20
      t.string   "phone_cell",             limit: 20
      t.string   "phone_office",           limit: 20
      t.string   "fax",                    limit: 20
      t.string   "avatar"
      t.integer  "department_id",          default: 2,     null: false
      t.integer  "root_dept_id"
      t.boolean  "approved",                                          default: false, null: false
      t.string   "login",                                             default: "",    null: false
      t.string   "encrypted_password",                                default: "",    null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count", default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at",                                                        null: false
      t.datetime "updated_at",                                                        null: false
    end

    add_index "users", ["approved"], name: "index_users_on_approved"
    add_index "users", ["login"], name: "index_users_on_login", unique: true
    add_index "users", ["reset_password_token"], name: "i_users_reset_password_token", unique: true

    table_comment :users, 'Пользователи системы'
    column_comment :users, :email, 'Электронный адрес'
    column_comment :users, :surname, 'Фамилия'
    column_comment :users, :name, 'Имя'
    column_comment :users, :patronymic, 'Отчество'
    column_comment :users, :user_job, 'Должность'
    column_comment :users, :phone_public, 'Городской телефон'
    column_comment :users, :phone_cell, 'Сотовый телефон'
    column_comment :users, :phone_office, 'Внутриофисный телефон'
    column_comment :users, :fax, 'Факс'
    column_comment :users, :department_id, 'ИД отдела'
    column_comment :users, :root_dept_id, 'Область видимости (головное подразделение)'
    column_comment :users, :approved, 'Активировация пользователя'
    column_comment :users, :login, 'Логин'

    create_table "users_plan_lots", id: false, force: true do |t|
      t.integer "user_id", null: false
      t.integer "plan_lot_id", null: false
    end

    table_comment :users_plan_lots, 'Выделенные план. лоты пользователей'
    column_comment :users_plan_lots, :user_id, 'ИД пользователя'
    column_comment :users_plan_lots, :plan_lot_id, 'ИД план. лота'

    create_table "versions", force: true do |t|
      t.string   "item_type",                                 null: false
      t.integer  "item_id", null: false
      t.string   "event",                                     null: false
      t.string   "whodunnit"
      t.text     "object"
      t.datetime "created_at"
      t.text     "object_changes"
    end

    add_index "versions", ["item_type", "item_id"], name: "i_versions_item_type_item_id"

    create_table :web_service_logs, comment: 'Лог запросов / ответов веб-сервиса' do |t|
      t.string :soap_action, null: false, comment: 'soap метод'
      t.string :ip, null: false, comment: 'IP запроса'
      t.string :remote_ip, null: false, comment: 'Originating IP address, usually set by the RemoteIp middleware'
      t.text :request_body, comment: 'тело запроса'
      t.text :response_body, comment: 'тело ответа'

      t.datetime :created_at, null: false
    end

    create_table "winner_protocol_lots", force: true do |t|
      t.integer  "winner_protocol_id", null: false
      t.integer  "lot_id", null: false
      t.integer  "solution_type_id", null: false
      t.datetime "created_at",                                    null: false
      t.datetime "updated_at",                                    null: false
    end

    add_index "winner_protocol_lots", ["lot_id"], name: "i_wp_lot"

    table_comment :winner_protocol_lots, 'Join Table WinnerProtocol to Lot'
    column_comment :winner_protocol_lots, :winner_protocol_id, 'Протокол ВП'
    column_comment :winner_protocol_lots, :lot_id, 'Лот'
    column_comment :winner_protocol_lots, :solution_type_id, 'Решение'

    create_table "winner_protocols", force: true do |t|
      t.integer  "tender_id", null: false
      t.string   "num",                                     null: false
      t.date     "confirm_date",                            null: false
      t.date     "vote_date"
      t.datetime "created_at",                              null: false
      t.datetime "updated_at",                              null: false
    end

    add_index "winner_protocols", ["tender_id"], name: "i_winner_protocols_tender_id"

    table_comment :winner_protocols, 'Протоколы выбора победителя'
    column_comment :winner_protocols, :tender_id, 'ИД тендера'
    column_comment :winner_protocols, :num, 'Номер'
    column_comment :winner_protocols, :confirm_date, 'Дата вступления в силу'
    column_comment :winner_protocols, :vote_date, 'Дата голосования'
  end
end
