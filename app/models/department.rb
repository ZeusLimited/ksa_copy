# frozen_string_literal: true

class Department < ApplicationRecord
  include Constants

  has_paper_trail

  attr_accessor :is_child

  has_one :arm_department
  has_many :commissions, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :plan_lots, dependent: :restrict_with_error
  has_many :tenders, dependent: :restrict_with_error
  has_many :spec_customers, class_name: 'Specification', foreign_key: 'customer_id', dependent: :restrict_with_error
  has_many :spec_consumers, class_name: 'Specification', foreign_key: 'consumer_id', dependent: :restrict_with_error
  has_many :plan_spec_customers,
           class_name: 'PlanSpecification',
           foreign_key: 'customer_id',
           dependent: :restrict_with_error
  has_many :plan_spec_consumers,
           class_name: 'PlanSpecification',
           foreign_key: 'consumer_id',
           dependent: :restrict_with_error
  has_one :contact, -> { where(version: 0) }, class_name: 'Contact'
  belongs_to :ownership, class_name: 'Ownership', foreign_key: 'ownership_id'
  has_one :monitor_service

  accepts_nested_attributes_for :contact

  scope :by_root, ->(dep_root) { where(id: dep_root.subtree_ids) }
  scope :root, ->(dept) { where(id: dept).root }

  scope :customers, -> { where(is_customer: true) }
  scope :organizers, -> { where(is_organizer: true) }
  scope :consumers, -> { where(is_consumer: true) }
  scope :by_name, ->(text) { where('lower(name) = lower(?)', text) }
  scope :monitor_services, -> { joins(:monitor_service).order(:fullname) }

  has_ancestry

  money_fields :tender_cost_limit, :eis223_limit

  with_options unless: :is_child do |d|
    d.validates :inn, presence: true, inn_format: true
    d.validates :kpp, presence: true, kpp_format: true
    d.validates :ownership_id, presence: true
  end

  validates :parent_dept_id, presence: true, if: :is_child
  validates :name, :fullname, presence: true, length: { maximum: 255 }
  validates :shortname, length: { maximum: 25 }

  delegate :legal_fias_name, :legal_fias_okato, to: :contact, prefix: true, allow_nil: true
  delegate :postal_fias_name, :postal_fias_okato, to: :contact, prefix: true, allow_nil: true
  delegate :email, :web, :phone, :fax, to: :contact, prefix: true, allow_nil: true
  delegate :shortname, to: :ownership, prefix: true, allow_nil: true
  delegate :fullname, to: :ownership, prefix: true, allow_nil: true

  def self.organizers_child_ids(array_ids)
    [].tap do |mas|
      array_ids.each { |dep_id| mas << find(dep_id).subtree.organizers.pluck(:id) }
      mas.flatten!.uniq!
    end
  end

  def self.customers_child_ids(array_ids)
    [].tap do |mas|
      array_ids.each { |dep_id| mas << find(dep_id).subtree.customers.pluck(:id) }
      mas.flatten!.uniq!
    end
  end

  def self.for_index(filter = 'parent_dept_id is null')
    sel = <<-SQL
      id, name, parent_dept_id,
      (select count(*) from departments p where p.parent_dept_id = departments.id) as have_children
    SQL
    depts = Department.select(sel)
    depts = depts.where(filter).order(:position)
    mas = []
    depts.each do |dept|
      children = dept.have_children > 0 ? Department.for_index("parent_dept_id = #{dept.id}") : []
      mas << {
        key: dept.id,
        title: dept.name,
        isFolder: dept.have_children > 0,
        href: "/departments/#{dept.id}/edit#{dept.parent_dept_id && '_child'}",
        children: children
      }
    end
    mas
  end

  def self.nodes_for_parent(parent_dept_id = nil)
    @filter_rows = Department.all
    tree_dept(parent_dept_id.try(&:to_i))
  end

  def self.nodes_for_filter(filter)
    @filter_rows = filter(filter)
    tree_dept
  end

  def self.tree_dept(parent_dept_id = nil)
    mas = []
    rows = @filter_rows.select { |r| r.parent_dept_id == parent_dept_id }
    rows = rows.sort_by(&:id)

    rows.each do |r|
      children = tree_dept(r.id)
      mas << { id: r.id, title: r.fullname, children: children }
    end
    mas
  end

  def self.filter(term)
    sub = Department
          .where('LOWER(name) LIKE LOWER(?) OR LOWER(fullname) LIKE ?', "%#{term}%", "#{term}%")
          .select('id, ancestry')
    ids = sub.map { |e| [e.id] + e.ancestor_ids }.flatten.uniq
    Department.where(id: ids)
  end

  def in_subtree?(dept_id)
    subtree_ids.include?(dept_id)
  end

  def subtree_ids
    @subtree_ids ||= super()
  end

  def name_with_depth_symbols(symbols = '&nbsp;&nbsp;')
    "#{symbols.to_s * depth} #{[ownership_shortname, name].compact.join(' ')}".gsub('"', '&quot;').html_safe
  end

  def self.customers_by_root(root_dep_id = nil)
    # Department.rank_array(root_dep_id, true).select { |d| d.is_customer == true }

    rank_array(root_dep_id, true, is_customer: true)
  end

  def self.organizers_by_root(root_dep_id = nil)
    # Department.rank_array(root_dep_id, true).select { |d| d.is_organizer == true }

    rank_array(root_dep_id, true, is_organizer: true)
  end

  def self.consumers_by_root(root_dep_id = nil)
    rank_array(root_dep_id, true, is_consumer: true)
  end

  def self.subtree_ids_for(value)
    array = Array(value).compact.uniq
    array.map { |e| Department.subtree_of(e).pluck(:id) }.flatten.uniq
  end

  def self.roots_customers(root_dep)
    deps = Department.customers.roots
    deps = deps.where(id: root_dep.root_id) if root_dep
    deps
  end

  def self.rank_array(root_dep_id = nil, need_self = true, where = {})
    depts = includes(:ownership).references(:ownership).where(where)
    depts = depts.where.not(id: root_dep_id) unless need_self
    depts = depts.where(id: subtree_ids_for(root_dep_id)) unless root_dep_id.blank?
    depts.sort_by(&:path_ids)
  end

  def self.search(term, dep_root_ids = nil, scope = nil)
    words = term.split ' '
    deps = Department.order(:name)
    deps = deps.where(id: subtree_ids_for(dep_root_ids)) if dep_root_ids
    deps = deps.send(scope) if scope
    words.each { |w| deps = deps.where("lower(name) like lower(?)", "%#{w}%") }
    deps
  end

  def self.define_by_name(dep_name, root_dept_id)
    Department.subtree_of(root_dept_id)
              .find_by('lower(name) = lower(:name) or lower(shortname) = lower(:name)', name: dep_name)
  end

  def self.define_org_by_name(dep_name, _root_dept_id)
    Department.organizers.find_by('lower(name) = lower(?)', dep_name)
  end

  def offname
    [ownership_shortname, name].join(' ')
  end

  def shortname
    super || name
  end
end
