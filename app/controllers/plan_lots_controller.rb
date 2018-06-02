# frozen_string_literal: true

class PlanLotsController < ApplicationController
  include Constants
  before_action :set_plan_filter, only: [:index, :export_excel, :export_excel_lot]
  before_action :set_plan_lot,
                only: [:edit_plan_specifications, :show, :edit, :update, :destroy, :edit_without_history, :update_without_history,
                       :destroy_version, :preselection_info]
  before_action :lock_edit, only: [:edit, :update, :edit_plan_specifications]
  before_action :check_lots_for_group_operation,
                only: [:submit_approval, :return_for_revision, :agree, :pre_confirm_sd]

  authorize_resource

  layout 'simple', only: [:import_lots, :history_lot_full]

  decorates_assigned :plan_lot

  def import_excel
    @import_lots = ImportLot.where(user_id: current_user.id).order(:num)
    @root_depts =
      if current_user.root_dept_id
        Department.where(id: @current_user.root_dept_id).map(&:root).uniq
      else
        Department.roots.order(:position)
      end

    @valid_lots_size = 0
    @invalid_lots_size = 0

    @import_lots.each do |import_lot|
      if import_lot.valid?
        @valid_lots_size += 1
      else
        @invalid_lots_size += 1
      end
    end
  end

  def import
    @import_lots = ImportLot.where(user_id: current_user.id).order(:num)
    if @import_lots.any?(&:invalid?)
      redirect_to import_excel_plan_lots_path, alert: t('.alert_error_list')
    else
      ImportLot.transaction do
        begin
          @import_lots.each do |import_lot|
            import_lot.create_plan_lot(params[:root_dept].to_i, current_user)
          end
          ImportLot.where(user_id: current_user.id).delete_all
          redirect_to(url_to_session_or_default(:filter_path, plan_lots_path),
                      notice: t('.notice')
          )
        rescue ActiveRecord::StatementInvalid
          redirect_to url_to_session_or_default(:filter_path, plan_lots_path),
                      alert: t('.alert_error')
        end
      end
    end
  end

  def import_lots
    @import_lots = ImportLot.where(user_id: current_user.id).order(:num)
  end

  def upload_excel
    begin
      PlanLot.import(params[:file], current_user)
    rescue => e
      redirect_to import_excel_plan_lots_path, alert: e.message
      return
    end
    redirect_to import_excel_plan_lots_path, notice: t('.notice')
  end

  def index
    if plan_filter_params.present?
      plan_filter_params.delete(:selected_lots)
      @plan_filter.valid?
      lots = @plan_filter.search
      respond_to do |format|
        format.html do
          @plan_lots = lots.page params[:page]
          @plan_selected_lots = current_user.plan_lots.page params[:page_sel]
          session[:filter_path] = plan_lots_path(plan_filter: plan_filter_params)
        end
        format.json { @plan_lots = lots }
      end
    end
  end

  def export_excel
    @plan_lots = @plan_filter.search_excel
    filename = "plan_lots_#{Time.current.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    render xlsx: "plan_lots", disposition: "attachment", filename: filename
  end

  def export_excel_lot
    @plan_lots = @plan_filter.search_excel_lot
    filename = "plan_lots_#{Time.current.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    render xlsx: "plan_lots", disposition: "attachment", filename: filename
  end

  def show
    redux_store(
      'SharedReduxStore',
      props: {
        meta: { ui: { eis_plan_lots: { eis_num: { id: @plan_lot.eis.id, num: @plan_lot.eis.num } } } },
      },
    )
  end

  def new
    @plan_lot = PlanLot.build_plan_lot(current_user, params, session)
  end

  def edit
    @plan_lot.is_additional = @plan_lot.additional_to?
  end

  def create
    @plan_lot = current_user.author_plan_lots.build(plan_lot_params)
    @plan_lot.actualize_state

    if @plan_lot.save
      save_params_to_session
      redirect_to @plan_lot, notice: t('.notice', num: @plan_lot.full_num)
    else
      render :new
    end
  end

  def update
    @plan_lot_old = PlanLot.find(params[:id])

    pl_params = plan_lot_params

    if pl_params[:plan_lots_files_attributes]
      pl_params[:plan_lots_files_attributes].values.each { |s| s.delete 'id' }
    end

    if pl_params[:plan_lot_contractors_attributes]
      pl_params[:plan_lot_contractors_attributes].values.each { |s| s.delete 'id' }
    end

    if pl_params[:plan_annual_limits_attributes]
      pl_params[:plan_annual_limits_attributes].values.each { |s| s.delete 'id' }
    end

    pl_params["plan_specifications_attributes"].values.each do |s|
      s.delete 'id'
      s["plan_spec_amounts_attributes"].values.each { |a| a.delete 'id' }
      s["fias_plan_specifications_attributes"].values.each { |a| a.delete 'id' }
    end

    @plan_lot = PlanLot.build_plan_lot_with_params(current_user, pl_params, @plan_lot_old)
    @plan_lot.actualize_state unless @plan_lot.can_edit_state?(current_user)

    if @plan_lot.save
      redirect_to @plan_lot, notice: t('.notice', num: @plan_lot.full_num)
    else
      render :edit
    end
  end

  def destroy_all
    unless current_user.plan_lots.all?(&:can_delete?)
      fail CanCan::AccessDenied, t('.notice')
    end
    current_user.plan_lots.each do |e|
      e.all_versions.each(&:destroy)
    end
    redirect_to url_to_session_or_default(:filter_path, plan_lots_path)
  end

  def destroy
    unless @plan_lot.can_delete?
      fail CanCan::AccessDenied, t('.notice')
    end
    @plan_lot.all_versions.each(&:destroy)

    redirect_to url_to_session_or_default(:filter_path, plan_lots_path)
  end

  def edit_without_history
    @plan_lot.is_additional = @plan_lot.additional_to?
  end

  def update_without_history
    if @plan_lot.update_attributes(plan_lot_params)
      @plan_lot.update_bind_execute
      redirect_to history_plan_lot_path(@plan_lot.guid_hex), notice: t('.notice', version: @plan_lot.version)
    else
      render :edit_without_history
    end
  end

  def destroy_version
    if @plan_lot.execute?
      redirect_to history_plan_lot_path(@plan_lot.guid_hex), alert: t('.alert')
    else
      @plan_lot.delete_version
      redirect_to history_plan_lot_path(@plan_lot.guid_hex), notice: t('.notice')
    end
  end

  def destroy_current_version_user
    curr_ver = PlanLot.current_version(params[:guid])
    if curr_ver.status_id != Constants::PlanLotStatus::NEW
      redirect_to history_plan_lot_path(params[:guid]), alert: t('.alert_new')
    else
      if curr_ver.user != current_user
        redirect_to history_plan_lot_path(params[:guid]), alert: t('.alert_author')
      else
        PlanLot.delete_current_version(params[:guid])
        redirect_to history_plan_lot_path(params[:guid]), notice: t('.notice')
      end
    end
  end

  def next_free_number
    dep = Department.find(params[:department_id]).root
    year = params[:gkpz_year]
    render plain: "В ГКПЗ #{year} года #{dep.name} следующий свободный номер закупки: " \
      "#{PlanLot.max_num_tender(year, dep)}"
  end

  def preselection_search
    @plan_lots = PlanLot.preselection_search(params[:q], params[:cust_id]).select_title_fields.limit(10)
  end

  def additional_search
    @plan_lots = PlanLot.additional_search(params[:q], params[:cust_id]).select_title_fields.limit(10)
  end

  def additional_info
    @plan_lot = PlanLot.all_versions(params[:guid]).first
  end

  def search_edit_list
    root_cust_id = current_user.plan_lots.first.root_customer_id
    @plan_lots = PlanLot.search_edit_list(params[:q], root_cust_id)
                        .select("id, num_tender, num_lot, lot_name, gkpz_year").limit(10)
  end

  def search_all
    @plan_lots = PlanLot.search_all(params[:q], params[:cust_id], params[:gkpz_years])
                        .select("id, num_tender, num_lot, lot_name, gkpz_year").limit(10)
  end

  def reset
    session[:plan_new] = nil
    session[:specification_new] = nil
    redirect_to new_plan_lot_url
  end

  def history_lot
    @plan_lot_current_version = PlanLot.current_version(params[:guid])
    @plan_lots = PlanLot.history(params[:guid]).decorate
  end

  def history_lot_full
    @plan_lot_current_version = PlanLot.current_version(params[:guid])
    @plan_lots = PlanLot.history(params[:guid]).decorate
  end

  def history_spec
    @plan_specifications = PlanSpecification.history(params[:guid]).decorate
  end

  def submit_approval
    authorize! :submit_approval, current_user
    error_lots = current_user.plan_lots.invalid_okved.map(&:full_num)
    error_lots << current_user.plan_lots.invalid_sme.map(&:full_num)
    if error_lots.flatten!.empty?
      standard_change_status(t('.alert'), t('.notice'), Constants::PlanLotStatus::UNDER_CONSIDERATION)
    else
      redirect_to url_to_session_or_default(:filter_path, plan_lots_path),
                  alert: t(".not_valid", lots: error_lots.uniq.join('<br />'))
    end
  end

  def return_for_revision
    authorize! :return_for_revision, current_user
    standard_change_status(t('.alert'), t('.notice'), Constants::PlanLotStatus::NEW)
  end

  def agree
    error_lots = current_user.plan_lots.invalid_okved.map(&:full_num)
    error_lots << current_user.plan_lots.invalid_sme.map(&:full_num)
    if error_lots.flatten!.empty?
      standard_change_status(t('.alert'), t('.notice'), Constants::PlanLotStatus::CONSIDERED)
    else
      redirect_to url_to_session_or_default(:filter_path, plan_lots_path),
                  alert: t(".not_valid", lots: error_lots.uniq.join('<br />'))
    end
  end

  def pre_confirm_sd
    authorize! :pre_confirm_sd, current_user
    error_lots = current_user.plan_lots.invalid_okved.map(&:full_num)
    error_lots << current_user.plan_lots.invalid_sme.map(&:full_num)
    if error_lots.flatten!.empty?
      standard_change_status(t('.alert'), t('.notice'), Constants::PlanLotStatus::PRE_CONFIRM_SD)
    else
      redirect_to url_to_session_or_default(:filter_path, plan_lots_path),
                  alert: t(".not_valid", lots: error_lots.uniq.join('<br />'))
    end
  end

  def cancel_pre_confirm_sd
    if current_user.plan_lots.any? { |l| l.status_id != Constants::PlanLotStatus::PRE_CONFIRM_SD }
      redirect_to(url_to_session_or_default(:filter_path, plan_lots_path),
                  alert: t('.alert')
      )
    else
      lots = current_user.plan_lots.map do |l|
        l.destroy
        PlanLot.reindex_versions(l.guid_hex)
        PlanLot.current_version(l.guid_hex)
      end
      current_user.clear_plan_lots
      current_user.plan_lots = lots
      redirect_to(url_to_session_or_default(:filter_path, plan_lots_path),
                  notice: t('.notice')
      )
    end
  end

  def reform_okveds
    @okdp = Okdp.find(params[:okdp]).reform unless params[:okdp].blank?
    @okved = Okved.find(params[:okved]).reform unless params[:okved].blank?
  end

  def preselection_info; end

  def edit_plan_specifications
    unless @plan_lot.can_add_spec?(current_user)
      fail CanCan::AccessDenied, t('.notice')
    end
    @plan_lot.is_additional = @plan_lot.additional_to?
    @plan_lot.add_plan_specifications(params[:ps_ids])
    render :edit
  end

  def copy_plan_specifications
    if current_user.plan_lots.select(:root_customer_id).distinct.count > 1
      fail CanCan::AccessDenied, t('.diff_root_customers')
    end
    @plan_lots = current_user.plan_lots
  end

  private

  def save_params_to_session
    session[:plan_new] = @plan_lot.session_params
    session[:specification_new] = @plan_lot.plan_specifications[0].session_params
  end

  def standard_change_status(alert, notice, new_status)
    notice = \
      unless current_user.exists_plan_lots_with_another_statuses?(PlanLotStatus::REQUIRED_FOR_ACTION[action_name.to_sym])
        ActiveRecord::Base.exec_procedure("pcg_gkpz.change_status(#{current_user.id},#{new_status})")
        { notice: notice }
      else
        { alert: alert }
      end
    redirect_to url_to_session_or_default(:filter_path, plan_lots_path), notice
  end

  def set_plan_lot
    @plan_lot = PlanLot.find(params[:id])
  end

  def set_plan_filter
    @plan_filter = PlanFilter.new(plan_filter_params&.merge(current_user: current_user))
  end

  def plan_filter_params
    params[:plan_filter]&.permit!
  end

  def lock_edit
    fail CanCan::AccessDenied, "Этот лот редактировать нельзя!" unless @plan_lot.can_edit?
    return if @plan_lot.users.empty?
    fail CanCan::AccessDenied, "Данный лот заблокирован, т.к. он находится в 'выбранных' у пользователей:" \
      " #{@plan_lot.users.map(&:fio_full).join(', ')}"
  end

  def plan_lot_params
    params.require(:plan_lot).permit(
      :num_tender, :num_lot, :lot_name, :department_id, :tender_type_id, :tender_type_explanations, :subject_type_id,
      :etp_address_id, :announce_date, :explanations_doc, :point_clause, :protocol_id, :status_id, :commission_id,
      :gkpz_year, :is_additional, :additional_num, :additional_to_hex, :state, :sme_type_id, :order1352_id, :charge_date,
      :order1352_fullname, :preselection_guid_hex, :regulation_item_id, :non_eis,
      plan_lot_contractors_attributes: [:id, :plan_lot_id, :contractor_id, :_destroy],
      plan_annual_limits_attributes: [
        :id, :_destroy, :plan_lot_id, :year, :cost, :cost_nds, :cost_money, :cost_nds_money
        ],
      plan_specifications_attributes: [
        :plan_lot_id, :num_spec, :qty, :cost, :cost_money, :cost_doc, :unit_id, :direction_id, :product_type_id,
        :bp_item, :bp_state_id, :financing_id, :consumer_id, :delivery_date_begin, :delivery_date_end, :name, :cost_nds,
        :cost_nds_money, :monitor_service_id, :okdp_id, :potential_participants, :curator, :tech_curator, :note,
        :customer_id, :requirements, :okved_id, :unit_name, :consumer_id, :nds, :gkpz_year, :invest_project_id,
        :invest_name, :guid_hex, :okdp_name, :okved_name, :id, :_destroy,
        production_unit_ids: [],
        plan_spec_amounts_attributes: [
          :plan_specification_id, :year, :amount_mastery, :amount_mastery_nds, :amount_finance, :amount_finance_nds,
          :amount_mastery_money, :amount_mastery_nds_money, :amount_finance_money, :amount_finance_nds_money, :id,
          :_destroy
        ],
        fias_plan_specifications_attributes: [
          :plan_specification_id, :fias_id, :addr_aoid_hex, :id, :_destroy
        ]
      ],
      plan_lots_files_attributes: [
        :plan_lot_id, :tender_file_id, :note, :file_type_id, :id, :_destroy
      ]
    )
  end
end
