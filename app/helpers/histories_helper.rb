module HistoriesHelper
  def association_name(object, key, value)
    if object.class == Contractor
      return t("contractor_status.#{value}") if key == 'status'
    end
    if key.end_with? "_id"
      title object.send(key[0..-4].to_sym).class.name.constantize.find(value)
    else
      localize(value)
    end
    rescue
      value
  end

  private

  def title(object)
    object.send(case object.class.name
                when 'User' then :fio_full
                when 'Lot' then :fullname
                when 'Commission' then :commission_type_name
                when 'Contract' then :title
                when 'Contractor' then :name_long
                when 'SubContractor' then :contractor_name_long
                else :name
                end)
  end

  def localize(value)
    value.class == Time ? value.getlocal(Time.zone.utc_offset) : value
  end
end
