module Reports
  module Reglament
    class TenderTypesResult < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i,
          customer: customer.to_i
        }.with_indifferent_access
      end

      def self.subrow_title(suffix, param = nil)
        I18n.t("#{to_s.underscore}.subrow_titles.#{suffix}", type: param)
      end

      ROWS = {
        row1:  { value: ->(r) { r['plan_cost'] }, height: 33, style_text: :th,           print_name: true },
        row2:  { value: ->(r) { r['fact_cost'] }, height: 50, style_text: :th,           print_name: true },
        row3:  { value: ->(r) { r['fact_cost_v'] }, height: 52, style_text: :th,           print_name: true },
        row4:  {
          value: ->(r) { row2(r) == 0 ? 0 : row3(r) / row2(r) },
          style: :td_percent,
          style_text: :th,
          print_name: true
        },
        row5:  { value: ->(r) { r['plan_cost_ok'] },     name: subrow_title('plan_cost'),          print_name: true },
        row6:  {
          value: ->(r) { row1(r) == 0 ? 0 : row5(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ОК'),
          style: :td_percent
        },
        row7:  { value: ->(r) { r['fact_cost_ok'] },     name: subrow_title('fact_cost')                            },
        row8:  { value: ->(r) { r['fact_cost_ok_v'] },   name: subrow_title('fact_cost_v')                          },
        row9:  {
          value: ->(r) { row2(r) == 0 ? 0 : row7(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ОК'),
          style: :td_percent
        },
        row10: { value: ->(r) { r['plan_cost_zk'] },     name: subrow_title('plan_cost'),          print_name: true },
        row11: {
          value: ->(r) { row1(r) == 0 ? 0 : row10(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ЗК'),
          style: :td_percent
        },
        row12: { value: ->(r) { r['fact_cost_zk'] },     name: subrow_title('fact_cost')                            },
        row13: { value: ->(r) { r['fact_cost_zk_v'] },   name: subrow_title('fact_cost_v')                          },
        row14: {
          value: ->(r) { row2(r) == 0 ? 0 : row12(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ЗК'),
          style: :td_percent
        },
        row15: { value: ->(r) { r['plan_cost_ozc'] },    name: subrow_title('plan_cost'),          print_name: true },
        row16: {
          value: ->(r) { row1(r) == 0 ? 0 : row15(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ОЗЦ'),
          style: :td_percent
        },
        row17: { value: ->(r) { r['fact_cost_ozc'] },    name: subrow_title('fact_cost')                            },
        row18: { value: ->(r) { r['fact_cost_ozc_v'] },  name: subrow_title('fact_cost_v')                          },
        row19: {
          value: ->(r) { row2(r) == 0 ? 0 : row17(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ОЗЦ'),
          style: :td_percent
        },
        row20: { value: ->(r) { r['plan_cost_zzc'] },    name: subrow_title('plan_cost'),          print_name: true },
        row21: {
          value: ->(r) { row1(r) == 0 ? 0 : row20(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ЗЗЦ'),
          style: :td_percent
        },
        row22: { value: ->(r) { r['fact_cost_zzc'] },    name: subrow_title('fact_cost')                            },
        row23: { value: ->(r) { r['fact_cost_zzc_v'] },  name: subrow_title('fact_cost_v')                          },
        row24: {
          value: ->(r) { row2(r) == 0 ? 0 : row22(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ЗЗЦ'),
          style: :td_percent
        },
        row25: { value: ->(r) { r['plan_cost_ozp'] },    name: subrow_title('plan_cost'),          print_name: true },
        row26: {
          value: ->(r) { row1(r) == 0 ? 0 : row25(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ОЗП'),
          style: :td_percent
        },
        row27: { value: ->(r) { r['fact_cost_ozp'] },    name: subrow_title('fact_cost')                            },
        row28: { value: ->(r) { r['fact_cost_ozp_v'] },  name: subrow_title('fact_cost_v')                          },
        row29: {
          value: ->(r) { row2(r) == 0 ? 0 : row27(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ОЗП'),
          style: :td_percent
        },
        row30: { value: ->(r) { r['plan_cost_zzp'] },    name: subrow_title('plan_cost'),          print_name: true },
        row31: {
          value: ->(r) { row1(r) == 0 ? 0 : row30(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ЗЗП'),
          style: :td_percent
        },
        row32: { value: ->(r) { r['fact_cost_zzp'] },    name: subrow_title('fact_cost')                            },
        row33: { value: ->(r) { r['fact_cost_zzp_v'] },  name: subrow_title('fact_cost_v')                          },
        row34: {
          value: ->(r) { row2(r) == 0 ? 0 : row32(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ЗЗП'),
          style: :td_percent
        },
        row35: { value: ->(r) { r['plan_cost_okp'] },    name: subrow_title('plan_cost'),          print_name: true },
        row36: {
          value: ->(r) { row1(r) == 0 ? 0 : row35(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ОКП'),
          style: :td_percent
        },
        row37: { value: ->(r) { r['fact_cost_okp'] },    name: subrow_title('fact_cost')                            },
        row38: { value: ->(r) { r['fact_cost_okp_v'] },  name: subrow_title('fact_cost_v')                          },
        row39: {
          value: ->(r) { row2(r) == 0 ? 0 : row37(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ОКП'),
          style: :td_percent
        },
        row40: { value: ->(r) { r['plan_cost_zkp'] },    name: subrow_title('plan_cost'),          print_name: true },
        row41: {
          value: ->(r) { row1(r) == 0 ? 0 : row40(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ЗКП'),
          style: :td_percent
        },
        row42: { value: ->(r) { r['fact_cost_zkp'] },    name: subrow_title('fact_cost')                            },
        row43: { value: ->(r) { r['fact_cost_zkp_v'] },  name: subrow_title('fact_cost_v')                          },
        row44: {
          value: ->(r) { row2(r) == 0 ? 0 : row42(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ЗКП'),
          style: :td_percent
        },
        row45: { value: ->(r) { r['plan_cost_ei'] },     name: subrow_title('plan_cost'),          print_name: true },
        row46: {
          value: ->(r) { row1(r) == 0 ? 0 : row45(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ЕИ'),
          style: :td_percent
        },
        row47: { value: ->(r) { r['fact_cost_ei'] },     name: subrow_title('fact_cost')                            },
        row48: { value: ->(r) { r['fact_cost_ei_v'] },   name: subrow_title('fact_cost_v')                          },
        row49: {
          value: ->(r) { row2(r) == 0 ? 0 : row47(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ЕИ'),
          style: :td_percent
        },
        row50: { value: ->(r) { r['fact_cost_eik'] },    name: subrow_title('fact_cost'),          print_name: true },
        row51: {
          value: ->(r) { row2(r) == 0 ? 0 : row50(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ЕУ'),
          style: :td_percent
        },
        row52: { value: ->(r) { r['plan_cost_nz'] },     name: subrow_title('plan_cost'),          print_name: true },
        row53: {
          value: ->(r) { row1(r) == 0 ? 0 : row52(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'НЗ'),
          style: :td_percent
        },
        row54: { value: ->(r) { r['fact_cost_nz'] },     name: subrow_title('fact_cost')                            },
        row55: { value: ->(r) { r['fact_cost_nz_v'] },   name: subrow_title('fact_cost_v')                          },
        row56: {
          value: ->(r) { row2(r) == 0 ? 0 : row54(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'НЗ'),
          style: :td_percent
        },
        row57: { value: ->(r) { r['plan_cost_a'] },      name: subrow_title('plan_cost'),          print_name: true },
        row58: {
          value: ->(r) { row1(r) == 0 ? 0 : row57(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'А'),
          style: :td_percent
        },
        row59: { value: ->(r) { r['fact_cost_a'] },      name: subrow_title('fact_cost')                            },
        row60: { value: ->(r) { r['fact_cost_a_v'] },    name: subrow_title('fact_cost_v')                          },
        row61: {
          value: ->(r) { row2(r) == 0 ? 0 : row59(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'А'),
          style: :td_percent
        },
        row62:  { value: ->(r) { r['plan_cost_po'] },     name: subrow_title('plan_cost'),          print_name: true },
        row63:  {
          value: ->(r) { row1(r) == 0 ? 0 : row62(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'ПО'),
          style: :td_percent
        },
        row64:  { value: ->(r) { r['fact_cost_po'] },     name: subrow_title('fact_cost')                            },
        row65:  { value: ->(r) { r['fact_cost_po_v'] },   name: subrow_title('fact_cost_v')                          },
        row66:  {
          value: ->(r) { row2(r) == 0 ? 0 : row64(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'ПО'),
          style: :td_percent
        },
        row67:  { value: ->(r) { r['plan_cost_uz'] },     name: subrow_title('plan_cost'),          print_name: true },
        row68:  {
          value: ->(r) { row1(r) == 0 ? 0 : row62(r) / row1(r) },
          name: subrow_title('plan_cost_dp', 'УЗ'),
          style: :td_percent
        },
        row69:  { value: ->(r) { r['fact_cost_uz'] },     name: subrow_title('fact_cost')                            },
        row70:  { value: ->(r) { r['fact_cost_uz_v'] },   name: subrow_title('fact_cost_v')                          },
        row71:  {
          value: ->(r) { row2(r) == 0 ? 0 : row64(r) / row2(r) },
          name: subrow_title('fact_cost_dp', 'УЗ'),
          style: :td_percent
        },
      }
      ROWS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end
