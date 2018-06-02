class NonPublicReasonValidator < ActiveModel::Validator
  LOCAL_SCOPE = [:non_public_reason_validator].freeze

  def validate(record)
    return unless record.plan_lot_announce_date &&
                  record.tender_announce_date &&
                  record.tender_announce_date > record.plan_lot_announce_date + 1.month &&
                  record.non_public_reason.blank?
    record.errors[:non_public_reason] << I18n.t('.non_public', scope: LOCAL_SCOPE)
  end
end
