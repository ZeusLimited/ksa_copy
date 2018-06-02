# frozen_string_literal: true

class B2bClassifier < ApplicationRecord

  has_ancestry

  validates :classifier_id, :name, presence: true
  scope :by_b2b_classifier_ids, ->(ids) { where(classifier_id: ids) }
  scope :search_by_name_or_id, ->(q) { where(["name ilike :q or classifier_id::text like :q", q: "%#{q}%"]) }

  def self.filter(term)
    sub = self.search_by_name_or_id(term).select('id, ancestry')
    ids = sub.map { |e| [e.id] + e.ancestor_ids }.flatten.uniq
    B2bClassifier.where(id: ids)
  end

  def self.nodes_for_filter(filter)
    @filter_rows = filter(filter)
    if @filter_rows.size > 1000
     [{
       key: nil,
       name: 'По данному фильтру возвращается слишком много значений, пожалуйста уточните параметры поиска.',
       expand: false,
       isFolder: false,
       isRoot: true
     }]
    else
      generate_tree
    end
  end

  def self.generate_tree(parent_id = 0)
    @filter_rows.select { |r| r.parent_classifier_id == parent_id }.sort_by(&:classifier_id).map do |r|
      children = generate_tree(r.classifier_id)
      {
        key: r.classifier_id,
        id: r.classifier_id,
        disabled: !children.empty?,
        name: r.has_children? ? r.name : "#{r.name} (выбрать)",
        expand: true,
        children: children,
        isFolder: !children.empty?,
        isRoot: r.parent_classifier_id.nil?
      }
    end
  end
end
