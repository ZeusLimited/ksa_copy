# frozen_string_literal: true

class User < ApplicationRecord
  include RailsSettings::Extend

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  enum gender: { female: 0, male: 1 }

  mount_uploader :avatar, AvatarUploader

  validates :login, :email, :department_id, presence: true
  validates :login, uniqueness: true
  validates :surname, :name, :patronymic, :user_job, presence: true
  validates :phone_public, :phone_cell, presence: true, on: :create
  validates :gender, presence: true

  validates :password, length: 4..20, on: :create
  validates :password, length: 4..20, on: :update, allow_blank: true

  validates :email, :user_job, :login, :encrypted_password, :reset_password_token, :current_sign_in_ip,
            :last_sign_in_ip, length: { maximum: 255 }
  validates :surname, :name, :patronymic, length: { maximum: 50 }
  validates :phone_public, :phone_cell, :phone_office, length: { maximum: 20 }

  validates_format_of :email, with: /\A[^<@]+@([^@\.]+\.)+[^@\.>]+\z/, allow_blank: true

  validates_confirmation_of :password
  # validates_length_of :password, :within => 4..20, :allow_blank => true
  validate :restrict_admin_role, on: :update
  def restrict_admin_role
    return if has_role?(:admin) || !has_admin_role?
    errors.add(:base, :restrict_admin)
  end

  has_one :main_contact

  belongs_to :department
  belongs_to :root_dept, class_name: "Department", foreign_key: "root_dept_id"

  has_many :assignments, dependent: :destroy
  has_many :contractors, dependent: :restrict_with_exception
  has_many :tender_files, dependent: :restrict_with_exception
  has_many :commission_users, dependent: :restrict_with_exception
  has_many :experts, dependent: :restrict_with_exception
  has_many :plan_lots, dependent: :restrict_with_exception
  has_many :tenders, dependent: :restrict_with_exception
  has_many :plan_lot_non_executions, dependent: :restrict_with_exception
  has_many :import_lots, dependent: :restrict_with_exception
  has_many :open_protocol_present_members, dependent: :restrict_with_exception
  has_many :protocol_users, dependent: :restrict_with_exception
  has_many :rebid_protocol_present_members, dependent: :restrict_with_exception
  has_many :tasks, dependent: :restrict_with_exception
  has_many :tender_requests, dependent: :restrict_with_exception
  has_many :control_plan_lots, dependent: :restrict_with_exception

  has_many :author_plan_lots, class_name: "PlanLot"
  has_many :undeclared_comments, class_name: 'PlanLotNonExecution'
  has_many :roles, through: :assignments
  has_many :subscribes, dependent: :destroy
  has_many :subscribe_notifications, -> { order("created_at desc") }, dependent: :destroy

  has_and_belongs_to_many :plan_lots, join_table: 'users_plan_lots'
  has_and_belongs_to_many :lots, join_table: 'cart_lots'

  accepts_nested_attributes_for :assignments, allow_destroy: true

  FULL_NAME = "surname || ' ' || name || ' ' || patronymic"
  scope :user_names, (
    lambda do |term|
      select("id, #{FULL_NAME} as fullname")
      .where("lower(#{FULL_NAME}) like lower(?)", "%#{term}%")
      .order(FULL_NAME)
    end
  )

  def dept_root
    assignments.map { |a| a.department && a.department.path_ids }.flatten.uniq.compact
  end

  def contractor_boss_email
    dept_root.map do |e|
      User.joins(:assignments)
        .find_by(assignments: { department_id: e, role_id: Role.find_by_name('ContractorBoss').id }).try(:email)
    end.compact
  end

  def info_from_ldap
    search_in_ldap([:mail, :name, :title, :othertelephone, :samaccountname, :telephonenumber, :mobile])
  end

  def update_photo_from_ldap
    result = search_in_ldap([:thumbnailphoto])
    return unless result.present?
    tempfile = Tempfile.new([login, ".jpg"])
    IO.binwrite(tempfile.path, result[:thumbnailphoto])
    tempfile.close
    self.avatar = File.open(tempfile.path)
    save
  end

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability
  delegate :name, to: :department, prefix: true, allow_nil: true
  delegate :name, to: :root_dept, prefix: true, allow_nil: true

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  def has_admin_role?
    assignments.any? { |a| a.role_id == Constants::Roles::ADMIN }
  end

  def self.admins
    Role.where(name: 'Admin').first.users
  end

  def fio_full
    "#{surname} #{name} #{patronymic}"
  end

  def fio_short
    "#{surname} #{name[0]}.#{patronymic[0]}."
  end

  def io_full
    "#{name} #{patronymic}"
  end

  def phone
    phone_public || phone_cell || ""
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def limit_depatment_customer_ids(dep_ids)
    root_dept ? dep_ids & Department.find(root_dept.root_id).subtree.customers.pluck(:id) : dep_ids
  end

  def rao_user?
    department.root_id == Constants::Departments::RAO
  end

  after_create :send_admin_mail
  def send_admin_mail
    AdminMailer.new_user_waiting_for_approval(self).deliver unless approved?
  end

  def self.send_reset_password_instructions(attributes = {})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if !recoverable.approved?
      recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end

  def self.search(term)
    return User.none if term.nil?
    select_fields = "u.id, email, surname, u.name, patronymic, user_job, phone_public, d.name as dept_name, avatar"
    q_filter = %w(email surname u.name patronymic d.name user_job phone_public).map do |field|
      "(lower(#{field}) like lower('%#{term}%'))"
    end
    select(select_fields)
      .from('users u')
      .joins('left join departments d on d.id = u.department_id')
      .where(q_filter.join(' OR '))
      .includes(:roles)
  end

  def exists_plan_lots_with_another_statuses?(statuses)
    plan_lots.where.not(plan_lots: { status_id: statuses }).exists?
  end

  def clear_plan_lots
    ActiveRecord::Base.connection.execute("delete from users_plan_lots where user_id = #{id}")
    plan_lots.reload
  end

  def insert_all_plan_lots(relation_plan_lots)
    clear_plan_lots
    ActiveRecord::Base.connection.execute("insert into users_plan_lots (user_id, plan_lot_id) " +
      relation_plan_lots.select("#{id}, plan_lots.id").to_sql)
    plan_lots.reload
  end

  def add_plan_lot_ids(plots_ids)
    PlanLot.find(plots_ids).each do |plan_lot|
      plan_lots << plan_lot unless plan_lots.exists?(plan_lot.id)
    end
  end

  def remove_plan_lot_ids(plots_ids)
    PlanLot.find(plots_ids).each do |plan_lot|
      plan_lots.delete(plan_lot) if plan_lots.exists?(plan_lot.id)
    end
  end

  def add_lot(lot_id)
    lot = Lot.find lot_id
    lots << lot unless lots.exists?(lot.id)
  end

  def remove_lot(lot_id)
    lot = Lot.find lot_id
    lots.delete(lot) if lots.exists?(lot.id)
  end

  def clear_cart_lots
    ActiveRecord::Base.connection.execute("delete from cart_lots where user_id = #{id}")
    lots.reload
  end

  def subscribe(plan_lot_guid)
    subscribes.where(plan_lot_guid: plan_lot_guid).take
  end

  def search_in_ldap(attributes)
    ldap = Ldap.new
    ldap.get_attributes(email, attributes)
  end

  def root_dept_id
    return @root_dept_id if defined? @root_dept_id
    @root_dept_id = begin
      ids = assignments.map(&:department_id)
      if ids.index(nil)
        root_dept_id = nil
      else
        root_dept_id = ids.compact
      end
    end
  end
end
