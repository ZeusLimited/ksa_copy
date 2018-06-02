module Reports
  module Other
    class AgentsCommission < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_years: gkpz_years
        }.with_indifferent_access
      end

      attr_accessor :lot_num, :plan_lot_statuses, :lot_statuses

      def self.zero_to_nil(numb)
        numb.nil? || numb.zero? ? nil : numb
      end

      def self.add_formuls(count)
        additional_columns = {}
        additional_formuls = {}
        count.times do |i|
          additional_formuls[(i + 19).to_s] = { formula:
                                                  lambda do |params|
                                                    detail_result = zero_to_nil(
                                                      params[:offers_array][i].to_s.tr(',', '.').to_f / 1000.0
                                                    )
                                                    %(=#{detail_result})
                                                  end }
          additional_columns["c#{i + 19}"] = { type: :string, width: 12, style: :td_money_alt, sum_style: :sum }
        end
        FORMULAS['exec_stage'].merge!(additional_formuls)
        COLUMNS.merge!(additional_columns)
      end

      FORMULAS = {
        'common' => {
          '01' => { value: ->(r) { I18n.t("#{to_s.underscore}.statuses.#{r['stage']}") } },
          '02' => { value: ->(r) { r['lot_num'] } },
          '03' => { value: ->(r) { r['lot_name'] } },
          '04' => { value: ->(r) { r['tender_type'] } },
          '05' => { value: ->(r) { r['credit'] } },
          '06' => { value: ->(r) { to_thousand(r['all_cost']) } },
          '07' => { value: ->(r) { to_thousand(r['all_nds_cost']) } },
          '08' => { value: ->(r) { zero_to_nil(to_thousand(r['final_winner_cost'])) } },
          '09' => { value: nil },
          '10' => { formula:
                     lambda do |params|
                       %(=I#{params[:row]}*1.18)
                     end },
          '11' => { value: ->(r) { zero_to_nil(r['offers_cnt']) } },
          '12' => { formula:
                      lambda do |params|
                        %(=N#{params[:row]}*0.1)
                      end },
          '13' => { formula:
                      lambda do |params|
                        %(=L#{params[:row]}*1.18)
                      end },
          '14' => { formula:
                      lambda do |params|
                        %(=IF(E#{params[:row]}="Да",IF(G#{params[:row]}>15000,375,
                          IF(G#{params[:row]}*2.5%>375,375,G#{params[:row]}*2.5%)),
                          IF(OR(D#{params[:row]}="ООК",D#{params[:row]}="ОА",
                          D#{params[:row]}="ЗОК",D#{params[:row]}="ЗА"),
                          IF(G#{params[:row]}>10000000,
                          IF(G#{params[:row]}*0.042%>5500,G#{params[:row]}*0.042%,5500),IF(G#{params[:row]}>5000000,
                          IF(G#{params[:row]}*0.05%>3725,G#{params[:row]}*0.05%,3725),IF(G#{params[:row]}>1500000,
                          IF(G#{params[:row]}*0.0725%>1340,G#{params[:row]}*0.0725%,1340),IF(G#{params[:row]}>750000,
                          IF(G#{params[:row]}*0.0845%>966,G#{params[:row]}*0.0845%,966),IF(G#{params[:row]}>350000,
                          IF(G#{params[:row]}*0.125%>467.5,G#{params[:row]}*0.125%,467.5),IF(G#{params[:row]}>=15000,
                          IF(G#{params[:row]}*0.1335%>375,G#{params[:row]}*0.1335%,375),IF(G#{params[:row]}<15000,
                          IF(G#{params[:row]}*2.5%<375,G#{params[:row]}*2.5%,375),1))))))),
                          IF(OR(D#{params[:row]}="ОЗП",D#{params[:row]}="ЗЗП"),
                          IF(G#{params[:row]}>10000000,IF(G#{params[:row]}*0.0085%>1000,G#{params[:row]}*0.0085%,1000),
                          IF(G#{params[:row]}>5000000,
                          IF(G#{params[:row]}*0.01%>750,G#{params[:row]}*0.01%,750),IF(G#{params[:row]}>1500000,
                          IF(G#{params[:row]}*0.015%>525,G#{params[:row]}*0.015%,525),IF(G#{params[:row]}>750000,
                          IF(G#{params[:row]}*0.035%>450,G#{params[:row]}*0.035%,450),IF(G#{params[:row]}>350000,
                          IF(G#{params[:row]}*0.06%>345,G#{params[:row]}*0.06%,345),
                          IF(15000<G#{params[:row]}<350000,345,
                          IF(345>G#{params[:row]}*2.5%,G#{params[:row]}*2.5%,345))))))),
                          IF(OR(D#{params[:row]}="ЗЗЦ",D#{params[:row]}="ОЗЦ"),
                          IF(G#{params[:row]}>750000,95,IF(G#{params[:row]}>350000,75,
                          IF(15000<G#{params[:row]}<350000,49.5,
                          IF(49.5>G#{params[:row]}*2.5%,G#{params[:row]}*2.5%,49.5)))),
                          IF(OR(D#{params[:row]}="ОМК",D#{params[:row]}="ЗМК",
                          D#{params[:row]}="ОКПКО",D#{params[:row]}="ЗКПКО"),
                          IF(G#{params[:row]}>10000000,IF(G#{params[:row]}*0.07%>7250,
                          G#{params[:row]}*0.07%,7250),IF(G#{params[:row]}>5000000,
                          IF(G#{params[:row]}*0.075%>5500,G#{params[:row]}*0.075%,5500),IF(G#{params[:row]}>1500000,
                          IF(G#{params[:row]}*0.11%>2150,G#{params[:row]}*0.11%,2150),IF(G#{params[:row]}>750000,
                          IF(G#{params[:row]}*0.14%>1500,G#{params[:row]}*0.14%,1500),
                          IF(G#{params[:row]}>350000,IF(G#{params[:row]}*0.2%>767.832,
                          G#{params[:row]}*0.2%,767.832),IF(G#{params[:row]}>=23000,
                          IF(G#{params[:row]}*0.375%>575,G#{params[:row]}*0.375%,575),IF(G#{params[:row]}<23000,
                          IF(G#{params[:row]}*2.5%<575,G#{params[:row]}*2.5%,575),1))))))),
                          IF(OR(D#{params[:row]}="ОКП",D#{params[:row]}="ЗКП"),
                          IF(G#{params[:row]}>10000000,IF(G#{params[:row]}*0.004%>450,
                          G#{params[:row]}*0.004%,450),IF(G#{params[:row]}>5000000,
                          IF(G#{params[:row]}*0.0045%>400,G#{params[:row]}*0.0045%,400),IF(G#{params[:row]}>1500000,
                          IF(G#{params[:row]}*0.008%>375,G#{params[:row]}*0.008%,375),IF(G#{params[:row]}>750000,
                          IF(G#{params[:row]}*0.025%>325,G#{params[:row]}*0.025%,325),
                          IF(G#{params[:row]}>350000,IF(G#{params[:row]}*0.04%>245,
                          G#{params[:row]}*0.04%,245),IF(15000<G#{params[:row]}<350000,245,
                          IF(245>G#{params[:row]}*2.5%,G#{params[:row]}*2.5%,245))))))),1)))))))
                      end },
          '15' => { formula:
                      lambda do |params|
                        %(=N#{params[:row]}*1.18)
                      end }
        },
        'exec_stage' => {
          '09' => { formula:
                      lambda do |params|
                        %(=IF(E#{params[:row]}="да",IF(G#{params[:row]}>15000,375,
                         IF(G#{params[:row]}*2.5%>375,375,G#{params[:row]}*2.5%)),
                         IF(N#{params[:row]}+P#{params[:row]}>G#{params[:row]}*5%,
                         G#{params[:row]}*5%,N#{params[:row]}+P#{params[:row]})))
                      end },
          '16' => { formula:
                      lambda do |params|
                        %(=IF(F#{params[:row]}<100000,R#{params[:row]}*8%,
                          IF(F#{params[:row]}<1000000,R#{params[:row]}*5%,R#{params[:row]}*3%))+
                          IF(G#{params[:row]}>200000,IF(K#{params[:row]}<2,N#{params[:row]}*0,
                          IF(K#{params[:row]}<6,N#{params[:row]}*0.1,
                          IF(K#{params[:row]}<11,N#{params[:row]}*0.2,N#{params[:row]}*0.3))),0))
                      end },
          '17' => { formula:
                      lambda do |params|
                        %(=P#{params[:row]}*1.18)
                      end },
          '18' => { formula:
                      lambda do |params|
                        %(=IF((#{EXCEL_COLUMNS[params[:add_columns_size] - 1]}#{params[:row]}
                        /#{EXCEL_COLUMNS[params[:add_columns_size]]}#{params[:row]}-H#{params[:row]})>0,
                        #{EXCEL_COLUMNS[params[:add_columns_size] - 1]}#{params[:row]}
                        /#{EXCEL_COLUMNS[params[:add_columns_size]]}#{params[:row]}-H#{params[:row]},0))
                      end },
          'last_1' => { formula:
                          lambda do |params|
                            %(=SUM(#{EXCEL_COLUMNS[19]}#{params[:row]}:
                            #{EXCEL_COLUMNS[params[:add_columns_size] - 2]}#{params[:row]}))
                          end },
          'last_2' => { formula:
                          lambda do |params|
                            %(=COUNT(#{EXCEL_COLUMNS[19]}#{params[:row]}:
                            #{EXCEL_COLUMNS[params[:add_columns_size] - 2]}#{params[:row]}))
                          end }
        },
        'plan_stage' => {
          '09' => { formula:
                      lambda do |params|
                        %(=IF(E#{params[:row]}="да",IF(G#{params[:row]}>15000,375,
                        IF(G#{params[:row]}*2.5%>375,375,G#{params[:row]}*2.5%)),
                        IF(N#{params[:row]}+P#{params[:row]}>G#{params[:row]}*5%,
                        G#{params[:row]}*5%,N#{params[:row]}+P#{params[:row]})))
                      end }
        },
        'cancel_before_open' => {
          '09' => { formula:
                     lambda do |params|
                       %(=N#{params[:row]}*0.5)
                     end }
        },
        'cancel_before_result' => {
          '09' => { formula:
                     lambda do |params|
                       %(=N#{params[:row]}*0.75)
                     end }
        },
        'fail' => {
          '09' => { formula:
                     lambda do |params|
                       %(=N#{params[:row]}*0.3)
                     end }
        }
      }

      COLUMNS = {
        'c01' => { type: :string, style: :td, width: 50 },
        'c02' => { type: :string, style: :td, width: 15 },
        'c03' => { type: :string, style: :td, width: 50 },
        'c04' => { type: :string, style: :td, width: 15 },
        'c05' => { type: :string, style: :td, width: 15 },
        'c06' => { type: :float, style: :td_money_alt, width: 25 },
        'c07' => { type: :float, style: :td_money_alt, width: 15 },
        'c08' => { type: :float, style: :td_money_alt, width: 15 },
        'c09' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c10' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c11' => { type: :integer, style: :td, width: 20 },
        'c12' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c13' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c14' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c15' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c16' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c17' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'c18' => { type: :string, width: 10, style: :td_money_alt, sum_style: :sum },
        'last_1' => { type: :string, width: 12, style: :td_money_alt, sum_style: :sum },
        'last_2' => { type: :string, style: :td, width: 20 }
      }

      EXCEL_COLUMNS = ['0'] + ('A'..'AZ').to_a

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end
