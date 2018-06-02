class NewBidderValidator < ActiveModel::Validator
  def validate(record)
    if record && record.tender.new_bidders?
      record.errors[:base] << "В закупке содержатся не актуализированные участники"
    end
  end
end
