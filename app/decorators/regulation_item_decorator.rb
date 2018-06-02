class RegulationItemDecorator < Draper::Decorator
  delegate_all

  def tender_type_names
    @tender_type_names ||= tender_types.map(&:name)
  end

  def row_class
    is_actual ? 'success' : 'mute'
  end
end
