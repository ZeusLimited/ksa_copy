module SpecError
  def message(caption, params = {})
    I18n.t("errors.messages.#{caption}", params)
  end

  def model_message(model, name, caption, params = {})
    I18n.t("activerecord.errors.models.#{model}.attributes.#{name}.#{caption}", params)
  end

  module_function :message, :model_message
end
