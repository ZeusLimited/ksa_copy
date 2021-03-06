# frozen_string_literal: true

module Constants
  NDS = 18 # Налог на добавленную стоимость 18%
  PRIORITY_TIMEZONES = [
    ActiveSupport::TimeZone['Moscow'],
    ActiveSupport::TimeZone['Ekaterinburg'],
    ActiveSupport::TimeZone['Novosibirsk'],
    ActiveSupport::TimeZone['Krasnoyarsk'],
    ActiveSupport::TimeZone['Irkutsk'],
    ActiveSupport::TimeZone['Yakutsk'],
    ActiveSupport::TimeZone['Vladivostok'],
    ActiveSupport::TimeZone['Magadan']
  ]

  ORACLE_MAX_IN_CLAUSE = 1_000

  IGNORE_HISTORY_FIELDS = %w(id guid plan_lot_guid created_at updated_at)

  OFFER_TYPES = [%w(Основная 0)] + (1..10).map { |index| ["Альтернативная №#{index}", index] }

  module SectionStatus
    STATUS_APPROVED = 13_005 # Утверждено
  end

  module SubjectType
    MATERIALS = 30_001 # Материалы
    SERVICES = 30_002 # Услуги
  end

  module OkdpSmeEtpType
    SME = 'МСП'
    ETP = 'ЭТП'
  end

  module ProductTypes
    PIR = 61_001 # ПИР
    SMR = 61_005
    PNR = 61_006
    GP = 61_007
    WORKS = 61_017

    WORK_TYPES_LIST = [PIR, SMR, PNR, GP, WORKS]
  end

  module FileType
    REESTR_MSP = 44_001 # Реестр
    NMCD = 17_003 # Рассчет НМЦД
  end

  module LotStatus
    NEW = 33_010 # Новый лот
    PUBLIC = 33_020 # Опубликован
    OPEN = 33_030 # Вскрытие
    REVIEW = 33_040 # Протокол рассмотрения отправлен на рассмотрение
    REVIEW_CONFIRM = 33_050 # Протокол рассмотрения рассмотрен
    REOPEN = 33_060 # Вскрытие (Переторжка)
    SW = 33_070 # Протокол ВП отправлен на рассмотрение
    SW_CONFIRM = 33_080 # Протокол ВП рассмотрен
    WINNER = 33_090 # Победитель определен
    RP_SIGN = 33_095 # Протокол о результатах подписан
    CONTRACT = 33_100 # Договор заключен
    FAIL = 33_110 # Несостоялся
    CANCEL = 33_120 # Отменена

    AFTER_OPEN = [REVIEW, REVIEW_CONFIRM, REOPEN, SW, SW_CONFIRM, WINNER, RP_SIGN, CONTRACT, FAIL, CANCEL]
    NOT_NEW = AFTER_OPEN + [PUBLIC, OPEN]
    BEFORE_OPEN = [NEW, PUBLIC]
    NOT_HELD = [NEW, PUBLIC, OPEN, REVIEW, REVIEW_CONFIRM, REOPEN, SW, SW_CONFIRM]
    FATAL = [FAIL, CANCEL]
    NOT_HELD_WITH_FAIL = NOT_HELD + FATAL
    HELD = [WINNER, RP_SIGN, CONTRACT]
    HELD_WITH_FAIL = HELD + [FAIL]
    HELD_WITH_CANCEL = HELD + [CANCEL]
    HELD_WITH_FATAL = HELD + FATAL
    SWP = [OPEN, REVIEW_CONFIRM, REOPEN]
    FOR_WP = [PUBLIC, OPEN, REVIEW, REVIEW_CONFIRM, REOPEN]
  end

  module PlanLotStatus
    # NEW = 15001 # Новый
    # CONFIRM = 15002 # Утверждённый
    # EXCLUDED = 15003 # Исключённый
    # PRE_CONFIRM = 15004 # На утверждении
    # NOT_CONFIRM = 15005 # Не утверждённый

    NEW = 15_001 # Новый
    UNDER_CONSIDERATION = 15_002 # На рассмотрении
    AGREEMENT = 15_003 # Согласован
    CANCELED = 15_004 # Отменён
    PRE_CONFIRM_SD = 15_005 # На утверждении СД
    CONFIRM_SD = 15_006 # Утверждён СД
    EXCLUDED_SD = 15_007 # Исключён СД
    CONSIDERED = 15_008 # Рассмотрен
    IMPORT = 15_009 # Импортированный

    GKPZ = [CONFIRM_SD, EXCLUDED_SD]
    AGREEMENT_LIST = [AGREEMENT, CONFIRM_SD]
    CANCELLED_LIST = [CANCELED, EXCLUDED_SD]
    DELETED_LIST = [IMPORT, NEW]
    NOT_DELETED_LIST = [AGREEMENT, CANCELED, CONFIRM_SD, EXCLUDED_SD]
    EDIT_LIST = [IMPORT, NEW, AGREEMENT, CONFIRM_SD]
    PROTOCOL_ZK_LIST = [AGREEMENT, CANCELED]
    PROTOCOL_SD_LIST = [CONFIRM_SD, EXCLUDED_SD]

    REQUIRED_FOR_ACTION = {
      submit_approval: [NEW, AGREEMENT, CONFIRM_SD],
      return_for_revision: [UNDER_CONSIDERATION, CONSIDERED],
      agree: [UNDER_CONSIDERATION],
      new_protocol_zk: [CONSIDERED, AGREEMENT, CONFIRM_SD],
      pre_confirm_sd: [AGREEMENT, CONFIRM_SD, CANCELED],
      cancel_pre_confirm_sd: [PRE_CONFIRM_SD],
      new_protocol_sd: [PRE_CONFIRM_SD],
      new_tenders: [AGREEMENT, CONFIRM_SD],
      new_unregulated: [AGREEMENT, CONFIRM_SD]
    }
  end

  module Departments
    RAO = 2 # id ОАО «РАО ЭС Востока»
    RGS = 1000059
    ZAO_BLAG_TEC = 1_000_019
    ZAO_SAH_GRES2 = 1_000_020
    ZAO_SG_TEC = 1_000_021
    ZAO_YAKUT_GRES2 = 1_000_022
    RUSGIDROS_ZAO = [ZAO_BLAG_TEC, ZAO_SAH_GRES2, ZAO_SG_TEC, ZAO_YAKUT_GRES2]
  end

  module CoverLabels
    REQUEST = 22_001 # Заявка/Предложение
  end

  module StateSecrets
    SECRET = 29_002 #Секретно
    TOP_SECRET = 29_003 #Совершенно секретно
    MOST_IMPORTANT = 29_004
    ALL = [SECRET, TOP_SECRET, MOST_IMPORTANT]
  end

  module Financing
    COST_PRICE = 11_001 # 1.1 себестоимость
    PROFIT = 11_002 # 1.2 прибыль
    OWN_FUND = 11_003 # 2.1 собственные средства
    OWN_PROFIT = 11_004 # 2.1.1 прибыль
    OWN_AMORTIZING = 11_005 # 2.1.2 амортизация
    OWN_RETURN_NDS = 11_006 # 2.1.3 возврат НДС
    OWN_OTHER_FUND = 11_007 # 2.1.4 прочие собственные средства
    OWN_BALANCE_FUND = 11_008 # 2.1.5 остаток собственных средств на начало года
    RAISED_FUNDS = 11_009 # 2.2 привлеченные средства
    RAISED_CREDITS = 11_010 # 2.2.1 кредиты
    RAISED_BOND_ISSUES = 11_011 # 2.2.2 облигационные займы
    RAISED_CORPORATE_LOANS = 11_012 # 2.2.3 займы организаций
    RAISED_BUDGET_FUNDIN = 11_013 # 2.2.4 бюджетное финансирование
    RAISED_FOREIGN_INVESTORS = 11_014 # 2.2.5 средства внешних инвесторов
    RAISED_USE_LEASING = 11_015 # 2.2.6 использование лизинга
    RAISED_OTHER_FUNDS = 11_016 # 2.2.7 прочие привлеченные средства

    GROUP1 = [COST_PRICE, PROFIT]
    GROUP2 = [
      OWN_PROFIT, OWN_AMORTIZING, OWN_RETURN_NDS, OWN_OTHER_FUND, OWN_BALANCE_FUND, RAISED_CREDITS, RAISED_BOND_ISSUES,
      RAISED_CORPORATE_LOANS, RAISED_BUDGET_FUNDIN, RAISED_FOREIGN_INVESTORS, RAISED_USE_LEASING, RAISED_OTHER_FUNDS,
      OWN_FUND, RAISED_FUNDS
    ]

    INVALID_GROUP = [OWN_FUND, RAISED_FUNDS]
  end

  module Units
    DEFAULT_UNIT = '876' # Код ОКИЕ = 876, Значение = "усл. ед"
  end

  module TenderFileArea
    PLAN_LOT = 1
    TENDER = 2
    BIDDER = 3
    CONTRACT = 4
    PROTOCOL = 5
    CONTRACTOR = 6
    ORDER = 7
    CONTRACTOR_SINGLE_SOURCE = 8
  end

  module TenderFileType
    CONTRACT = 25_012
    ADDITIONAL_CONTRACT = 25_013
    REPLACEMENT = 25_018

    CONTRACTS = [CONTRACT, ADDITIONAL_CONTRACT]
  end

  module EtpAddress
    NOT_ETP = 12_001
    B2B_ENERGO = 12_002
    EETP = 12_004

    ETP = [B2B_ENERGO, EETP]
  end

  module TaskStatuses
    WORK = 1 # В работе
    DONE = 2 # Выполнено
    CANCEL = 3 # Отклонено
  end

  module TenderTypes
    OOK = 10_001 # Открытый одноэтапный конкурс
    ZOK = 10_002 # Закрытый одноэтапный конкурс
    OMK = 10_003 # Открытый многоэтапный конкурс
    ZMK = 10_004 # Закрытый многоэтапный конкурс
    OCK = 10_005 # Открытый ценовой конкурс
    ZCK = 10_006 # Закрытый ценовой конкурс
    OA = 10_007 # Открытый аукцион
    ZA = 10_008 # Закрытый аукцион
    OKP = 10_009 # Открытые конкурентные переговоры
    ZKP = 10_010 # Закрытые конкурентные переговоры
    OZP = 10_011 # Открытый запрос предложений
    ZZP = 10_012 # Закрытый запрос предложений
    OZC = 10_013 # Открытый запрос цен
    ZZC = 10_014 # Закрытый запрос цен
    ONLY_SOURCE = 10_015 # Единственный источник
    UNREGULATED = 10_016 # Нерегламентированная закупка
    ZPP = 10_017 # Закупка, путем участия в процедурах, организованных продавцом закупки
    ORK = 10_018 # Открытый конкурс (на рамочное соглашение)
    ZRK = 10_019 # Закрытый конкурс (на рамочное соглашение)
    PO = 10_020 # Предварительный отбор
    SIMPLE = 10_021 # Упрощенная закупка

    # NEW types
    OKO = 10_022 # открытый конкурс
    OKD = 10_023 # открытый конкурс (двухэтапный)
    OKM = 10_024 # открытый конкурс (многоэтапный)
    KEO = 10_025 # конкурс в электронной форме
    KED = 10_026 # конкурс в электронной форме (двухэтапный)
    KEM = 10_027 # конкурс в электронной форме (многоэтапный)
    ZKO = 10_028 # закрытый конкурс
    ZKD = 10_029 # закрытый конкурс (двухэтапный)
    ZKM = 10_030 # закрытый конкурс (многоэтапный)
    AE = 10_031 # аукцион в электронной форме
    AO = 10_032 # аукцион открытый
    AZ = 10_033 # аукцион закрытый
    ZPE = 10_034 # запрос предложений в электронной форме
    ZPO = 10_035 # запрос предложений открытый
    ZPZ = 10_036 # запрос предложений закрытый
    ZCE = 10_037 # запрос котировок в электронной форме
    ZCO = 10_038 # запрос котировок открытый
    ZCZ = 10_039 # запрос котировок закрытый
    MINI = 10_040 # мелкая закупка
    SINGLE_SOURCE = 10_041 # закупка у единственного поставщика (исполнителя, подрядчика)

    # GROUPS
    ALL = [OOK, ZOK, OMK, ZMK, OCK, ZCK, OA, ZA, OKP, ZKP, OZP, ZZP, OZC, ZZC, ONLY_SOURCE, UNREGULATED, ZPP, ORK, ZRK,
           PO, SIMPLE, OKO, OKD, OKM, KEO, KED, KEM, ZKO, ZKD, ZKM, AE, AO, AZ, ZPE, ZPO, ZPZ, ZCE, ZCO, ZCZ, MINI,
           SINGLE_SOURCE].freeze
    REGULATED = ALL - [UNREGULATED, MINI]

    OK = [OOK, OMK, OCK, ORK, OKO, OKD, OKM, KEO, KED, KEM].freeze
    ZK = [ZOK, ZMK, ZCK, ZRK, ZKO, ZKD, ZKM].freeze
    KP = [OKP, ZKP].freeze
    ZP = [OZP, ZZP, ZPE, ZPO, ZPZ].freeze
    ZC = [OZC, ZZC, ZCE, ZCO, ZCZ].freeze
    EI = [ONLY_SOURCE, ZPP, SINGLE_SOURCE].freeze

    NONCOMPETITIVE = [ONLY_SOURCE, UNREGULATED, MINI, SINGLE_SOURCE].freeze

    SME = [KEO, KED, KEM, AE, ZPE, ZCE].freeze
    SME_7_DAYS = [KEO, KED, KEM, AE].freeze
    BUSINESS_DAYS = [ZPE, ZPO, ZPZ, ZCE, ZCO, ZCZ].freeze

    ETP = SME
    NON_SME = [OKO, OKD, OKM, ZKO, ZKD, ZKM, AO, AZ, ZPO, ZPZ, ZCO, ZCZ, MINI, SINGLE_SOURCE].freeze
    NON_ETP = NON_SME + NONCOMPETITIVE + [SIMPLE]
    ORDER616_EXCLUSION = [ONLY_SOURCE, UNREGULATED, MINI, SINGLE_SOURCE, SIMPLE].freeze

    FAST = [OZC, ZZC, ORK, ZRK, OCK, ZCK, ZPP, SIMPLE, ONLY_SOURCE, UNREGULATED, ZCE, ZCO, ZCZ, MINI, SINGLE_SOURCE].freeze
    AUCTIONS = [OA, ZA].freeze
    TENDERS = OK + ZK

    ### TODO, or not TODO ###
    CAN_ONE_BIDDER = [ONLY_SOURCE, UNREGULATED, SINGLE_SOURCE, MINI].freeze # Уточнить так ли это
    OFFER_GUARANTIE = [AUCTIONS, TENDERS, PO].flatten # Anything else?
    NO_ALTERNATE_OFFERS = [AUCTIONS, ZC].flatten # Anything else?
    BANNED = [ORK, ZRK, OCK, ZCK].freeze # TODO, put all old types in the list, after July 1
    REBID_1_DAY = [OZP, ZZP, OKP, ZKP, OOK, ZOK, OMK, ZMK].freeze # Anything else?
    SW_MUST_3_DAYS = [OOK, ZOK, OMK, ZMK, ORK, OZP, ZZP, OCK, ZCK].freeze # Anything else?
    CLOSED = [ZOK, ZMK, ZCK, ZA, ZKP, ZZP, ZZC, ONLY_SOURCE, UNREGULATED, ZPP, ZRK].freeze # Anything else?
    CLOSED_WITHOUT_EI = [ZOK, ZMK, ZCK, ZA, ZKP, ZZP, ZZC, ZPP, ZRK].freeze # Anything else?

    ### DEPRECATED ####
    ROSSTAT_OTHER_OPEN = [OKP, OZP, OZC, ZPP].freeze # ROSSTAT
    ROSSTAT_OTHER_CLOSE = [ZKP, ZZP, ZZC].freeze # ROSSTAT
    ROSSTAT_EI = [ONLY_SOURCE, UNREGULATED].freeze # ROSSTAT
    INTEGRATED_TENDER = [OOK, ZOK, OMK, ZMK, OKP, ZKP].freeze # For link b2b_energo
    FRAMES = [ORK, ZRK].freeze # Frames are no longer awailable
    FOR_PO = [ZZC, ZZP, ZOK, ZMK, ZKP].freeze # PO is not longer awailable
  end

  module ContentOfferType
    HR = 24_001 # Справка о кадровых ресурсах
    MTR = 24_002 # МТР
  end

  module CommissionType
    LEVEL1_KK = 28_001 # 1 уровень КК
    LEVEL2_KK = 28_002 # 2 уровень КК
    SZK = 28_003 # СЗК
    CZK = 28_004 # ЦЗК
    SD = 28_005 # СД
    PDZK = 28_006 # ПДЗК

    EXECUTE_GROUP = [LEVEL1_KK, LEVEL2_KK, SZK, CZK, PDZK]
    MAIN_GROUP = [CZK, SD]
  end

  module Commissioners
    BOSS = 14_001 # Председатель
    SUB_BOSS = 14_002 # Заместитель председателя
    CLERK = 14_003 # Ответственный секретарь
    MEMBER = 14_004 # Член
  end

  module OfferTypes
    OFFER = 22_001 # Заявка/Предложение
    PICKUP = 22_002 # Отзыв
    REPLACE = 22_003 # Изменение заявки
  end

  module OfferStatuses
    NEW = 26_001 # Первичная
    RECEIVE = 26_002 # Принята
    REJECT = 26_003 # Отклонена
    WIN = 26_004 # Победила
  end

  module ContractTypes
    BASIC = 37_001 # Основной
    REDUCTION = 37_002 # На уменьшение стоимости
  end

  module ContractTerminationTypes
    AGREEMENT = 27_001
    COURT = 27_002
    REFUSAL = 27_003
  end

  module WinnerProtocolSolutionTypes
    WINNER = 40_001
    SINGLE_SOURCE = 40_002
    FAIL = 40_003
    CANCEL = 40_004
  end

  module Order1352
    SELECT = 41_001
    NOT_SELECT = 41_002
    EXCLUSIONS = (41_003..41_022).map(&:to_i)
    ALL = (41_001..41_022).map(&:to_i)
  end

  module SmeTypes
    SME = 36_001
    SUB_SME = 36_002
  end

  module ContractorSmeTypes
    SE = 39_001
    ME = 39_002
  end

  module SubscribeActions
    CONFIRM = 42_001
    PUBLIC = 42_002
    OPEN = 42_003
    REVIEW = 42_004
    REVIEW_CONFIRM = 42_005
    REOPEN = 42_006
    WINNER = 42_007
    WINNER_CONFIRM = 42_008
    RESULT = 42_009
    CONTRACT = 42_010
    FAIL = 42_011
    CANCEL = 42_012
    DELETE = 42_013
    CANCEL_PLAN = 42_014
    CONFIRM_SD = 42_015
    EXCLUDED_SD = 42_016
  end

  module SubscribeWarnings
    PUBLIC = 43_001
    OPEN = 43_002
    SUMMARIZE = 43_003
    ALL = [PUBLIC, OPEN, SUMMARIZE]
  end

  module Destinations
    TEX = 13_001 # Тех
  end

  module FormatMeetings
    FULL_TIME = 16_001 # Очная
    EXTRAMURAL = 16_002 # Заочная
    PART_TIME = 16_003 # Очно-заочная
  end

  module VostekTenders
    USERS = [
      333, # Глушкова
      420, # Дидух
      459, # Гриднева
      486, # Слипченко
      490, # Каушнян
      600, # Шатаева
      700, # Понуровская
      704, # Шишкин
      716, # Шорохов
      1018 # Решетова
    ]
  end

  module Roles
    ADMIN = 6
    MODERATOR = 7
    USER_BOSS = 8
  end
end
