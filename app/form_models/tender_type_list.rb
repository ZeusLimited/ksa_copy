class TenderTypeList
  include ActiveModel::Model

  attr_accessor :rules

  def save_with_rules!
    rules.each do |rule|
      dic = Dictionary.find(rule.first)
      dic.update(rule.last)
    end
  end
end
