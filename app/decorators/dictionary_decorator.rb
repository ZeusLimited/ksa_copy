# frozen_string_literal: true

class DictionaryDecorator < Draper::Decorator
  delegate_all

  TYPE_DECORATOR = ->(type) { [type.name, type.id, { 'title' => type.fullname }] }

  def self.grouped_tender_types(scope = Dictionary.tender_types)
    [
      ['Старые способы', scope.where('ref_id <= ?', Constants::TenderTypes::SIMPLE).map(&TYPE_DECORATOR)],
      ['Новые способы',  scope.where('ref_id >  ?', Constants::TenderTypes::SIMPLE).map(&TYPE_DECORATOR)],
    ]
  end
end
