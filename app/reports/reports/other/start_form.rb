module Reports
  module Other
    class StartForm < Reports::Base
      attr_accessor :current_user_root_dept

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/start_form_detail.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year ? gkpz_year.map(&:to_i) : nil,
          start_date: gkpz_year.blank? ? date_begin.to_date : Date.new(gkpz_year[0].to_i, 1, 1)
        }.with_indifferent_access
      end

      def part1_rows(filter)
        columns = [
          part_1_1_sql_rows,
          part_1_2_1_sql_rows,
          part_1_2_2_sql_rows,
          part_1_2_3_sql_rows,
          part_1_2_4_sql_rows
        ]
        united_columns(columns.map do |rows|
          rows.select do |row|
            filter.all? { |k, v| v.nil? || Array(v).include?(row[k.to_s]) }
          end
        end)
      end

      def united_columns(all_columns)
        all_columns.inject({}) do |c1, c2|
          c1.merge c2.empty? ? {} : merge_rows(c2)
        end
      end

      def merge_rows(rows)
        rows.inject do |h1, h2|
          h1.merge(h2) do |k, o, n|
            SUMMARY_COLUMNS.include?(k) ? o + (n || 0) : o
          end
        end
      end

      SUMMARY_COLUMNS = [
        "plan_count",
        "plan_cost",
        "all_plan_count",
        "all_plan_cost",
        "public_count",
        "public_cost",
        "all_public_count",
        "all_public_cost",
        "plan_public_count",
        "plan_public_cost",
        "all_plan_public_count",
        "all_plan_public_cost",
        "lag_count",
        "lag_cost",
        "all_lag_count",
        "all_lag_cost",
        "fact_count",
        "fact_cost",
        'gkpz_count',
        'gkpz_sum',
        'czk_count',
        'czk_sum',
        'tg_count',
        'tg_sum',
        'td_count',
        'td_sum'
      ]

      def part2_rows(customer, filter)
        params = default_params.merge(customer: customer).merge(filter.with_indifferent_access)
        select_all(sanitize_sql([part2, params]))
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      def rows
        @rows ||= YAML.load(ERB.new(File.read("#{structures}/start_form.yml")).result(binding))
      end

      def rows_with_organizers
        return rows unless @organizers
        @rows_with_organizers ||= @organizers.map do |organizer|
          {
            name: organizer_name(organizer),
            dir: Direction.pluck(:id),
            org: organizer.to_i,
            style: :td_right
          }
        end
        rows + @rows_with_organizers
      end

      COLUMNS = {
        c0: { type: :string, style: :td, width: 20, sum_style: :sum },
        c1: { type: :integer, style: :td, value: ->(r) { r['plan_count'] }, width: 10, sum_style: :sum },
        c2: { type: :float, style: :td_money, value: ->(r) { r['plan_cost'] }, width: 15, sum_style: :sum_money },
        c3: { type: :integer, style: :td, value: ->(r) { r['all_plan_count'] }, width: 10, sum_style: :sum },
        c4: { type: :float, style: :td_money, value: ->(r) { r['all_plan_cost'] }, width: 15, sum_style: :sum_money },
        c5: { type: :integer, style: :td, value: ->(r) { r['public_count'] }, width: 10, sum_style: :sum },
        c6: { type: :float, style: :td_money, value: ->(r) { r['public_cost'] }, width: 15, sum_style: :sum_money },
        c7: { type: :integer, style: :td, value: ->(r) { r['plan_public_count'] }, width: 10, sum_style: :sum },
        c8: { type: :float, style: :td_money, value: ->(r) { r['plan_public_cost'] }, width: 15, sum_style: :sum_money },
        c9: { type: :integer, style: :td, value: ->(r) { r['all_public_count'] }, width: 10, sum_style: :sum },
        c10: { type: :float, style: :td_money, value: ->(r) { r['all_public_cost'] }, width: 15, sum_style: :sum_money },
        c11: { type: :integer, style: :td, value: ->(r) { r['all_plan_public_count'] }, width: 10, sum_style: :sum },
        c12: { type: :float, style: :td_money, value: ->(r) { r['all_plan_public_cost'] }, width: 15, sum_style: :sum_money },

        c13: { type: :integer, value: ->(r) { r['lag_count'] }, width: 10, style: :td, sum_style: :sum },
        c14: { type: :float, value: ->(r) { r['lag_cost'] }, width: 15, style: :td_money, sum_style: :sum_money },
        c15: { type: :integer, value: ->(r) { r['all_lag_count'] }, width: 10, style: :td, sum_style: :sum },
        c16: { type: :float, value: ->(r) { r['all_lag_cost'] }, width: 15, style: :td_money, sum_style: :sum_money },

        # c13: { type: :string, formula: ->(i) { "=B#{i}-H#{i}" }, width: 10, style: :td, sum_style: :sum },
        # c14: { type: :string, formula: ->(i) { "=C#{i}-I#{i}" }, width: 15, style: :td_money, sum_style: :sum_money },
        # c15: { type: :string, formula: ->(i) { "=D#{i}-L#{i}" }, width: 10, style: :td, sum_style: :sum },
        # c16: { type: :string, formula: ->(i) { "=E#{i}-M#{i}" }, width: 15, style: :td_money, sum_style: :sum_money },
        c17: { type: :string, formula: ->(i) { "=H#{i}/B#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c18: { type: :string, formula: ->(i) { "=I#{i}/C#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c19: { type: :string, formula: ->(i) { "=L#{i}/D#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c20: { type: :string, formula: ->(i) { "=M#{i}/E#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c21: { type: :integer, style: :td, value: ->(r) { r['fact_count'] }, width: 10, sum_style: :sum },
        c22: { type: :float, style: :td_money, value: ->(r) { r['fact_cost'] }, width: 15, sum_style: :sum_money },
        c23: { type: :string, formula: ->(i) { "=J#{i}-V#{i}" }, width: 10, style: :td, sum_style: :sum },
        c24: { type: :string, formula: ->(i) { "=K#{i}-W#{i}" }, width: 15, style: :td_money, sum_style: :sum_money },
        c25: { type: :float, value: ->(r) { r['gkpz_count'] }, width: 15, style: :td_money, sum_style: :sum },
        c26: { type: :float, value: ->(r) { r['gkpz_sum'] }, width: 15, style: :td_money, sum_style: :sum_money },
        c27: { type: :float, value: ->(r) { r['czk_count'] }, width: 15, style: :td_money, sum_style: :sum },
        c28: { type: :float, value: ->(r) { r['czk_sum'] }, width: 15, style: :td_money, sum_style: :sum_money },
        c29: { type: :float, value: ->(r) { r['tg_count'] }, width: 15, style: :td_money, sum_style: :sum },
        c30: { type: :float, value: ->(r) { r['tg_sum'] }, width: 15, style: :td_money, sum_style: :sum_money },
        c31: { type: :float, value: ->(r) { r['td_count'] }, width: 15, style: :td_money, sum_style: :sum },
        c32: { type: :float, value: ->(r) { r['td_sum'] }, width: 15, style: :td_money, sum_style: :sum_money },
        c33: { type: :string, formula: ->(i) { "=AD#{i}/Z#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c34: { type: :string, formula: ->(i) { "=AE#{i}/AA#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c35: { type: :string, formula: ->(i) { "=AF#{i}/AB#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c36: { type: :string, formula: ->(i) { "=AG#{i}/AC#{i}" }, width: 10, style: :td_percent, sum_style: :sum_percent },
        c37: { type: :string, style: :td, width: 20, sum_style: :sum }
      }

      DETAIL_COLUMNS = {
        c1: { type: :integer, style: :td, width: 05 },
        c2: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 15 },
        c3: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 60 },
        c4: { type: :string, style: :td, value: ->(r) { r['direction_name'] }, width: 15 },
        c5: { type: :string, style: :td, value: ->(r) { r['lot_state'] }, width: 15 },
        c6: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 40 },
        c7: { type: :string, style: :td, value: ->(r) { r['consumer_name'] }, width: 30 },
        c8: { type: :string, style: :td, value: ->(r) { r['ctype_name'] }, width: 15 },
        c9: { type: :float, style: :td_money, value: ->(r) { r['plan_cost'] }, sum: true, width: 20 },
        c10: { type: :string, style: :td, value: ->(r) { r['sme_type_name'] }, width: 30 },
        c11: { type: :string, style: :td, value: ->(r) { r['ttype_name'] }, width: 15 },
        c12: { type: :date, style: :td_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 15 },
        c13: { type: :string, style: :td, value: ->(r) { r['reason'] }, width: 60 },
        c14: { type: :string, style: :td, value: ->(r) { r['monitor_services'] }, width: 60 },
        c15: { type: :string, style: :td, value: ->(r) { r['curators'] }, width: 25 },
        c16: { type: :string, style: :td, value: ->(r) { r['tech_curators'] }, width: 25 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      DETAIL_COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      private

      def organizer_name(org)
        [Department.find(org).name, " для ДЗО"].join
      end
    end
  end
end
