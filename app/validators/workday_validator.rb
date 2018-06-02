class WorkdayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && !value.workday?
      record.errors[attribute] << (options[:message] || "не может быть нерабочим днём")
    end
  end
end
