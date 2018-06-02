class ActiveRecord::Base
  extend MigrationHelper
  include ActionView::Helpers::NumberHelper
  include MigrationHelper

  def self.money_fields(*fields)
    fields.each do |f|
      define_method("#{f}_money") do
        val = read_attribute(f)
        val ? number_with_precision(val, precision: 2, delimiter: ' ') : nil
      end
      define_method("#{f}_money=") do |e|
        e = e.gsub(' ', '').gsub(',', '.') if e.is_a?(String)
        write_attribute(f, e)
      end
    end
  end

  def self.hex_fields(*fields)
    fields.each do |f|
      define_method("#{f}_hex") do
        val = read_attribute(f)
        self.class.guid_field(val)
      end
      define_method("#{f}_hex=") do |e|
        if e.present? && e.is_a?(String)
          e = UUIDTools::UUID.parse(e).raw if oracle_adapter?
          write_attribute(f, e)
        end
      end
    end
  end

  def self.compound_datetime_fields(*fields)
    fields.each do |f|
      define_method("compound_#{f}") do
        CompoundDatetime.new(read_attribute(f))
      end
      define_method("compound_#{f}_attributes=") do |e|
        val = send("compound_#{f}").assign_attributes(e).datetime
        write_attribute(f, val)
      end
    end
  end

  def self.guid_field(val)
    if oracle_adapter?
      val ? UUIDTools::UUID.parse_raw(val).to_s : nil
    else
      val
    end
  end

  def self.guid_eq(field_name, guid)
    return where([field_name.to_s, "=", "hextoraw(?)"].join(' '), guid.try(:gsub, '-', '')) if oracle_adapter? && guid.presence
    where(field_name => guid.presence)
  end

  def self.guid_in(field_name, guids)
    guids.select! { |guid| !guid.blank? }
    return where(guids.map { |guid| [field_name.to_s, "=", "hextoraw('#{guid.try(:gsub, '-', '')}')"].join(' ') }.join(' OR ')) if oracle_adapter?
    where(field_name => guids)
  end

  def self.guid_not_eq(field_name, guid)
    return where([field_name.to_s, "<>", "hextoraw(?)"].join(' '), guid.try(:gsub, '-', '')) if oracle_adapter? && guid.presence
    where.not(field_name => guid.presence)
  end

  def self.concatinate(field_name, delimiter = "', '", order_by = nil)
    order = order_by || field_name
    if oracle_adapter?
      "listagg(#{field_name}, #{delimiter}) within group (order by #{order})"
    elsif postgres_adapter?
      "string_agg(#{field_name}, #{delimiter} order by #{order})"
    end
  end

  def self.exec_procedure(procedure_name_with_params)
    if oracle_adapter?
      connection.execute("Begin #{procedure_name_with_params}; End;")
    elsif postgres_adapter?
      connection.execute("select #{procedure_name_with_params};")
    end
  end
end
