class ActualSubscribeDecorator < Draper::Decorator
  include Constants
  delegate_all

  def title
    return action_name if days_before.nil?
    [action_name,
     ":",
     I18n.t(:residue, count: days_before),
     I18n.t('datetime.distance_in_words.x_days', count: days_before)
    ].join(' ')
  end

  def background_class
    return "warning" if SubscribeWarnings::ALL.include? action_id
    action_id == SubscribeActions::DELETE ? "alert" : "success"
  end
end
