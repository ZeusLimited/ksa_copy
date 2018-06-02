# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    @user = user
    user.assignments.includes(:role, :department).references(:role).order('roles.position').each do |a|
      send(a.role_name.underscore, a.department)
    end
    # user.roles.order('roles.position').each { |role| send(role.name.underscore) }

    alias_action :create, :read, :update, :destroy, to: :crud
    alias_action :create, :update, :destroy, to: :cud
  end

  def admin(dept = nil)
    can :manage, :all
  end

  def moderator(dept)
    user_boss(dept)
    can :manage, [Dictionary, Page, PageFile, User, Department] if @user.root_dept_id.blank?
    can :manage, Protocol if @user.plan_lots.all? { |pl| user_customer?(pl.plan_specifications, dept) }
    can [:edit_without_history, :update_without_history, :destroy_version, :edit_state], PlanLot do |pl|
      user_customer?(pl.plan_specifications, dept)
    end
    can :manage, :tender_type_rule if @user.root_dept_id.blank?
    can :change_public_cost, Specification do |s|
      user_customer?(s, dept)
    end
    can :update, WinnerProtocolLot
    can :update_confirm_date, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept)
    end
    can :update_confirm_date, WinnerProtocol
    can :delete_list, :control_plan_lot
    can :manage, RegulationItem
    can :manage, UnfairContractor
    can :manage, EffeciencyIndicator
    can :manage, MainContact
    can :manage, Ownership
    can :manage, MonitorService
    can :manage, Direction
    can :manage, TenderDatesForType
  end

  def user_boss(dept)
    user(dept)
    can :manage, OkdpSmeEtp
    can :create, Protocol if plan_lots_owner?(@user.plan_lots, dept)
    can [:agree, :cancel_pre_confirm_sd], PlanLot
    can :return_for_revision, User
    can :manage, [Expert]
    can :manage, InvestProject
    can :crud, Contractor
    can :choose_for_customers, Commission
    can [:competition], :report
    can :public, Tender do |t|
      user_organizer?(t, dept) && (t.only_source? || t.announce_date <= Date.current)
    end
    can :show_protocols, Tender do |t|
      t.only_source? || t.local_bid_date <= Time.now
    end
    can :create, OpenProtocol do |op|
      user_organizer?(op.tender, dept) && (op.tender_only_source? || op.tender_local_bid_date <= Time.now)
    end

    can :confirm, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.review_lots?
    end
    can :revoke_confirm, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_confirm?
    end
    can :cancel_confirm, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_review?
    end

    can :confirm, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.win_lots?
    end
    can :revoke_confirm, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.all_lots_confirm?
    end
    can :cancel_confirm, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.all_lots_win?
    end

    can :create_list, ControlPlanLot
    can :delete_list, :control_plan_lot do
      !@user
        .plan_lots
        .joins('left join control_plan_lots cpl on (plan_lots.guid = cpl.plan_lot_guid)')
        .where('cpl.user_id is null or cpl.user_id != ?', @user.id)
        .exists?
    end
  end

  def user(dept)
    view(dept)
    can [:approve, :destroy], Order do |order|
      dept.nil? || dept.in_subtree?(order.plan_lots.last&.department_id)
    end
    can [:read, :create, :update], Order
    can :read, OkdpSmeEtp
    can :manage, :import_plan_lot
    can :update, EisPlanLot
    can [:create, :destroy, :destroy_all], PlanLot do |pl|
      user_customer?(pl.plan_specifications, dept)
    end
    can [
      :reset, :search_contractor, :import_excel, :import, :import_lots, :upload_excel, :next_free_number,
      :history_lot, :history_spec, :history_lot_full, :destroy_current_version_user, :preselection_search,
      :reform_okveds, :additional_search, :additional_info, :export_excel, :return_for_revision,
      :submit_approval, :pre_confirm_sd, :search_edit_list, :search_all, :edit_plan_specifications,
      :copy_plan_specifications
    ], PlanLot
    can :update, PlanLot do |pl|
      pl.version.zero? && user_customer?(pl.plan_specifications, dept)
    end
    can :add_to_user_plan_lots, PlanLot do |pl|
      pl.version.zero? || Constants::PlanLotStatus::NOT_DELETED_LIST.include?(pl.status_id)
    end
    can [:submit_approval, :pre_confirm_sd], User do |u|
      plan_lots_owner?(u.plan_lots, dept)
    end
    can :return_for_revision, User do |u|
      !u.plan_lots.where.not(status_id: Constants::PlanLotStatus::UNDER_CONSIDERATION).exists? &&
        plan_lots_owner?(u.plan_lots, dept)
    end
    can :edit_charge_date, PlanLot do |pl|
      @user.department.id == Constants::Departments::RGS && pl.department.id == Constants::Departments::RGS
    end
    can [:read, :contracts, :show_standard_form, :search_b2b_classifiers, :get_b2b_classifier], Tender
    can [:cud, :new_from_copy, :create_from_copy, :add_zzc, :copy, :offers], Tender do |t|
      user_organizer?(t, dept)
    end
    can :public, Tender do |t|
      user_organizer?(t, dept) && t.announce_date <= Date.current
    end
    can :tender_auction?, Tender do |t|
      t.tender? || t.auction?
    end

    can :have_lots_for_result_protocol?, Tender do |t|
      t.lots.for_result_protocol.exists?
    end

    can :update, Tender do |t|
      edit_tender?(t, dept)
    end

    can [:update], :contract_expired

    can :cud, Bidder do |b|
      user_organizer?(b.tender, dept)
    end
    can :cud, DocTaker do |dt|
      user_organizer?(dt.tender, dept)
    end
    can :cud, TenderRequest do |tr|
      user_organizer?(tr.tender, dept)
    end
    can :cud, Cover do |c|
      user_organizer?(c.tender, dept)
    end
    can [:cud, :control, :add, :pickup], Offer do |o|
      user_organizer?(o.tender, dept)
    end

    can [:update, :present_members], OpenProtocol do |op|
      user_organizer?(op.tender, dept)
    end
    can :create, OpenProtocol do |op|
      user_organizer?(op.tender, dept) && op.tender_local_bid_date <= Time.now
    end
    can :destroy, OpenProtocol do |op|
      user_organizer?(op.tender, dept) && !op.tender.lots_with_status?(Constants::LotStatus::AFTER_OPEN)
    end

    can :create, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept)
    end
    can [:destroy, :update], ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_open?
    end
    can :pre_confirm, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.open_lots?
    end
    can :confirm, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.review_lots? && rp.tender.in_limit?
    end
    can :revoke_confirm, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_confirm? && rp.tender.in_limit?
    end
    can :cancel_confirm, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_review? && rp.tender.in_limit?
    end
    can :update_confirm_date, ReviewProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_confirm?
    end

    can :present_members, RebidProtocol do |rp|
      user_organizer?(rp.tender, dept)
    end
    can :create, RebidProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_review_confirm?
    end
    can [:update, :destroy], RebidProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_reopen?
    end

    can :create, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept)
    end
    can [:destroy, :update], WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.all_lots_before_pre_confirm?
    end
    can :pre_confirm, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.reopen_lots?
    end
    can :confirm, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.win_lots? && wp.tender.in_limit?
    end
    can :revoke_confirm, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.all_lots_confirm? && wp.tender.in_limit?
    end
    can :cancel_confirm, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.all_lots_win? && wp.tender.in_limit?
    end
    can :sign, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.confirm_lots?
    end
    can :revoke_sign, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.all_lots_sign_or_fail?
    end
    can :update_confirm_date, WinnerProtocol do |wp|
      user_organizer?(wp.tender, dept) && wp.all_lots_confirm?
    end

    can :update, WinnerProtocolLot do |wpl|
      user_organizer?(wpl.lot.tender, dept) && Constants::LotStatus::FOR_WP.include?(wpl.lot_status_id)
    end

    can [:create, :update], ResultProtocol do |rp|
      user_organizer?(rp.tender, dept)
    end
    can :destroy, ResultProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_winner?
    end
    can :sign, ResultProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.winner_lots?
    end
    can :revoke_sign, ResultProtocol do |rp|
      user_organizer?(rp.tender, dept) && rp.all_lots_sign?
    end
    can [:index, :edit_all, :update_all], :tender_document
    can [:show, :edit, :update], :tender_data_map

    can [:read, :update, :create, :additional_search, :additional_info], Contract
    can :destroy, Contract do |c|
      c.children.empty?
    end
    can :manage, SubContractor
    can :manage, [PlanSpecification]
    can :manage, [FiasPlanSpecification, PlanSpecAmount]
    can [:create, :update, :read, :filter_rows_for_select, :filter_invest_names], InvestProject
    can [:destroy], InvestProject do |ip|
      ip.plan_specifications.empty?
    end
    can :manage, [TenderFile, PlanLotsFile]
    can :manage, Declension
    can :manage, LocalTimeZone
    can [:read, :create, :update, :for_organizer, :destroy], Commission
    can [:search], User
    can :change_public_cost, Specification do |s|
      s.lot_status_id.nil? ? true : Constants::LotStatus::BEFORE_OPEN.include?(s.lot_status_id)
    end
    can :create_contract, Lot do |lot|
      Lot.for_contract.where(tender_id: lot.tender_id).pluck(:id).include?(lot.id)
    end
    can :read, [Department, Okdp, Okved, Unit, Dictionary, OkdpReform]
    can :reduction, Dictionary
    can :read, Protocol
    can :search, [Department, Unit]
    can [:crud, :info_from_1c, :change_status], Contractor
    can [:search_from_old, :info, :search, :search_bidders, :search_potential_bidders], Contractor
    can :manage, :contractor_document
    can :manage, :user_plan_lot
    can :index, :tender_type_rule
    can [:read, :for_type], RegulationItem
    can [:read], Ownership
    can [:read], MonitorService
    can :read, Direction
    can :read, TenderDatesForType
    can :create, Fias
    can :read, Fias
    can :order1352_reg_item, Dictionary
    can :manage, :report
    cannot :competition, :report
  end

  def correct_lot(dept)
    can [:edit_without_history, :update_without_history], PlanLot do |pl|
      user_customer?(pl.plan_specifications, dept)
    end
  end

  def contractor_boss(dept = nil)
    can :manage, Contractor
    can :read, :contractor_document
    can :manage, :contractors_rename
  end

  def manage_wiki(dept = nil)
    can :manage, [Page, PageFile]
  end

  def contractor_creator(dept)
    view(dept)
    can [:create, :update, :info_from_1c], Contractor
    can :read, :contractor_document
  end

  def view(dept)
    can :read, Order
    can :read, SubContractor
    can [:read, :export_excel, :export_excel_lot, :preselection_info,
      :history_lot, :history_spec, :history_lot_full], PlanLot do |pl|
      user_customer?(pl.plan_specifications, dept)
    end
    can :read, PlanSpecification
    can :read, [FiasPlanSpecification, PlanSpecAmount]
    can :read, [InvestProject]
    can :read, [TenderFile, PlanLotsFile]
    can :read, WinnerProtocol
    can :index, :tender_document
    can [:search, :info], User

    can :reduction, Dictionary
    can :read, Protocol
    can [:read, :tenders, :find_by_inn, :search_reports], Contractor
    can :read, Lot do |l|
      user_customer?(l.specifications, dept)
    end

    can :read, [Department, Okdp, Okved, Unit]
    can [:nodes_for_parent, :nodes_for_filter, :reform_old_value], Okdp
    can [:nodes_for_parent, :nodes_for_filter], Okved
    can [:read, :contracts, :export_excel], Tender
    can [:frame_info], Lot
    can :read, Specification
    can :read, DocTaker
    can [:read, :map_by_lot, :map_pivot, :all_files_as_one], Bidder
    can :read, TenderRequest
    can :read, Cover
    can :read, Offer
    can :read, OfferSpecification
    can [:read, :reference], OpenProtocol
    can :read, ReviewProtocol
    can [:read, :reference], RebidProtocol
    can :read, WinnerProtocol
    can :read, ResultProtocol
    can [:read], Commission
    can :read, Contract
    can [:read, :export_excel], UnfairContractor
    can :read, EffeciencyIndicator
    can :manage, :report
    can :file_exists, Bidder
    can :read, MainContact
    cannot :competition, :report
    can :show_protocols, Tender do |t|
      t.local_bid_date <= Time.now
    end
    can :read, Page do |p|
      p.permalink != 'zakupHelp' || @user.department.root_id == Constants::Departments::RAO
    end
  end

  def view_plan(dept)
    can :read, Order
    can [:read, :export_excel, :export_excel_lot, :preselection_info, :history_lot,
      :history_spec, :history_lot_full], PlanLot do |pl|
      user_customer?(pl.plan_specifications, dept)
    end
    can [:preselection_search, :additional_search, :additional_info, :search_all], PlanLot
    can :read, PlanSpecification
    can :read, [FiasPlanSpecification, PlanSpecAmount]
    can :read, [InvestProject]
    can :read, [PlanLotsFile]
    can [:search, :info], User

    can :reduction, Dictionary
    can :read, Protocol
    can [:read, :tenders, :find_by_inn, :search_reports], Contractor

    can :read, [Department, Okdp, Okved, Unit]
    can [:nodes_for_parent, :nodes_for_filter], Okdp
    can [:nodes_for_parent, :nodes_for_filter], Okved
    can [:read, :export_excel], UnfairContractor
    can :read, EffeciencyIndicator
    can :read, MainContact
    can :read, Page do |p|
      p.permalink != 'zakupHelp' || @user.department.root_id == Constants::Departments::RAO
    end
  end

  def cannot_all
    # cannot [:create, :update, :destroy], PlanLot, status_id: Constants::PlanLotStatus::EXCLUDED
  end

  private

  def user_organizer?(tender, department)
    department.nil? ||
      Constants::Departments::RUSGIDROS_ZAO.include?(department.id) ||
      department.in_subtree?(tender.department_id)
  end

  def edit_tender?(tender, department)
    root_customers = tender.lots.pluck(:root_customer_id).uniq
    department.nil? ||
      Constants::Departments::RUSGIDROS_ZAO.include?(department.id) ||
      ((root_customers.size == 1 && root_customers[0] == department.id) ||
        department.in_subtree?(tender.department_id))
  end

  def user_customer?(specifications, department)
    department.nil? ||
      Constants::Departments::RUSGIDROS_ZAO.include?(department.id) ||
      Array(specifications).all? { |ps| department.in_subtree?(ps.customer_id) }
  end

  def plan_lots_owner?(plan_lots, department)
    department.nil? ||
      (plan_lots.joins(:plan_specifications).pluck('distinct customer_id') - department.subtree_ids).blank?
  end
end
