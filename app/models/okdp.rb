# frozen_string_literal: true

class Okdp < ApplicationRecord
  include Constants
  self.table_name = "okdp"

  has_many :plan_specifications

  has_ancestry

  scope :by_type, ->(type) { where(ref_type: type) }

  def self.nodes_for_parent(parent_id = nil)
    nodes = where(parent_id: parent_id).order(:id)
    mas = []
    nodes.each do |n|
      count_children = where(parent_id: n.id).count
      mas << { key: n.id,
               title: n.fullname,
               isLazy: count_children > 0,
               isFolder: count_children > 0,
               isRoot: n.parent_id.nil? }
    end
    mas
  end

  def self.nodes_for_filter(filter, type)
    @filter_rows = filter(filter, type)
    if @filter_rows.size > 50
      mas = []
      mas << { key: nil,
               name: 'По данному фильтру возвращается слишком много значений, пожалуйста уточните параметры поиска.',
               expand: false,
               isFolder: false,
               isRoot: true }
      mas
    else
      gen_dynatree
    end
  end

  def self.reform_old_value(new_value)
    OkdpReform.where(new_value: new_value).order(:old_value).last
  end

  def reform
    new_code = OkdpReform.find_by_old_value(code).try(:new_value)
    return if new_code.nil?
    Okdp.find_by(ref_type: 'OKPD2', code: new_code)
  end

  def fullname
    [code, name].join ' - '
  end

  def self.filter(term, type)
    sub = Okdp
          .where(ref_type: type)
          .where('LOWER(name) LIKE LOWER(?) OR code LIKE ?', "%#{term}%", "#{term}%")
          .select('id, ancestry')

    ids = sub.map { |e| [e.id] + e.ancestor_ids }.flatten.uniq
    ids.in_groups_of(ORACLE_MAX_IN_CLAUSE, false).reduce([]) do |results, array|
      results + Okdp.where(id: array)
    end
  end

  private

  def self.find_parent_rows(okdp_rows, parent_ids = [])
    parent_ids = okdp_rows.map(&:parent_id).uniq - parent_ids - [nil]
    parents = Okdp.find parent_ids
    parents = find_parent_rows parents, parent_ids unless parents.empty?

    okdp_rows + parents
  end

  def self.gen_dynatree(parent_id = nil)
    mas = []
    rows = @filter_rows.select { |r| r.parent_id == parent_id }.sort_by(&:code)

    rows.each do |r|
      children = gen_dynatree(r.id)
      mas << { key: r.id,
               id: r.id,
               title: r.fullname,
               code: r.code,
               name: r.name,
               expand: true,
               children: children,
               isFolder: !children.empty?,
               isRoot: r.parent_id.nil? }
    end
    mas
  end
end
