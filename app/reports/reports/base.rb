# frozen_string_literal: true

module Reports
  class Base
    include ActiveModel::Model
    include ActiveRecord::Sanitization::ClassMethods
    include MigrationHelper
    include Constants

    attr_accessor :table_name, :current_user_root_dept_id
    attr_accessor :date_begin, :date_end, :date_gkpz_on_state, :gkpz_type, :format
    attr_accessor :gkpz_years, :customers, :organizers, :tender_types, :directions, :financing_sources, :subject_types
    attr_accessor :statuses, :etp_addresses
    attr_accessor :gkpz_year, :customer, :organizer, :tender_type, :direction, :financing_source, :subject_type

    def initialize(args)
      super(args)
      initalize_sql_queries
    end

    def connection
      @connection ||= ActiveRecord::Base.connection
    end

    STATE_TYPES = {
      'Внеплан' => 0,
      'План' => 1,
    }.freeze

    GKPZ_TYPES = {
      'Вce (ГКПЗ+Внеплан)' => 'all_gkpz_unplanned',
      'ГКПЗ' => 'gkpz',
      'Внеплановые закупки' => 'unplanned',
      'Текущие (не утвержденные)' => 'current',
    }.freeze

    def dir_structures
      Rails.root.join('app', 'views', class_name, 'structures')
    end

    def default_params
      {
        begin_date: date_begin.to_date,
        end_date: date_end.to_date,
      }
    end

    def holding_name
      'ПАО «РусГидро»'
    end

    def structures
      Rails.root.join('app', 'views', 'reports', 'structures', Setting.company)
    end

    def yaml_directions
      @default_directions ||= Direction.all.inject({}) { |a, e| a.merge(e.yaml_key => e.id) }
    end

    def render_sql(file)
      ERB.new(File.new(File.join(sql_directory, file)).read).result(binding)
    end

    private

    def sql_directory
      File.join(Dir.pwd, "app", "reports", class_name)
    end

    def class_name
      self.class.to_s.underscore
    end

    def select_all(sql)
      change_type_map { connection.select_all(sql) }
    end

    def change_type_map(&block)
      return yield unless ActiveRecord::Base.postgres_adapter?
      type_map = connection.raw_connection.type_map_for_results
      connection.raw_connection.type_map_for_results = PG::BasicTypeMapForResults.new(connection.raw_connection)
      result = yield
      connection.raw_connection.type_map_for_results = type_map
      result
    end

    def initalize_sql_queries
      Dir[File.join(sql_directory, "[^_]*.sql.erb")].each do |file|
        attribute = File.basename(file, ".sql.erb")
        self.class.class_eval "attr_accessor attribute"
        send("#{attribute}=", render_sql(File.basename(file)))

        method_name = "#{attribute}_sql_rows"
        instance_variable = "@" + method_name
        define_singleton_method(method_name) do
          instance_variable_set(instance_variable, select_all(sanitize_sql([eval(attribute), default_params]))) \
            unless instance_variable_defined?(instance_variable)
          instance_variable_get(instance_variable)
        end
      end
    end
  end
end
