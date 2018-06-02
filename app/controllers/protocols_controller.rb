class ProtocolsController < ApplicationController
  include Constants
  authorize_resource

  before_action :set_all, only: [:show, :new, :create, :edit, :update, :destroy]

  def index
    @protocol_filter = ProtocolFilter.new(protocol_filter_params)
    @protocols = params[:protocol_filter].present? ? @protocol_filter.search : Protocol.none
    session[:protocol_filter_path] = protocols_path(protocol_filter: protocol_filter_params)
  end

  def show; end

  def new; end

  def edit; end

  def create
    if @protocol.save_with_discuss_plan_lots(current_user)

      redirect_to url_to_session_or_default(:filter_path, plan_lots_path), notice: t('.notice', num: @protocol.num)
    else
      render :new
    end
  end

  def update
    if @protocol.update_attributes(protocol_params)
      redirect_to @protocol, notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    fail CanCan::AccessDenied, t('.check_lots_exists') if @protocol.plan_lots.exists?
    @protocol.destroy

    redirect_to url_to_session_or_default(:protocol_filter_path, protocols_url)
  end

  def merge_new
    @protocol = Protocol.build_for_merge(params[:pids])
  end

  def merge_create
    @protocol = Protocol.new(protocol_params)

    if @protocol.merge_ids.present? && @protocol.save && @protocol.update_merge_protocols
      redirect_to @protocol, notice: t('.notice')
    else
      render :merge_new
    end
  end

  private

  def set_all
    if action_name == 'new'
      @protocol = Protocol.new(protocol_type: params[:type])
    elsif action_name == 'create'
      @protocol = Protocol.new(protocol_params)
    else
      @protocol = Protocol.find(params[:id])
    end

    checks if %w(new create).include?(action_name)

    dep_id = @protocol.persisted? ? @protocol.commission.department_id : current_user.plan_lots.take.root_customer_id
    set_commissions_and_statuses(@protocol, dep_id)
  end

  def set_commissions_and_statuses(protocol, dep_id)
    if protocol.sd?
      @commissions = Commission.confirm_group_sd(dep_id)
      @statuses = Dictionary.where(ref_id: PlanLotStatus::PROTOCOL_SD_LIST)
    else
      @commissions = Commission.confirm_group(dep_id)
      @statuses = Dictionary.where(ref_id: PlanLotStatus::PROTOCOL_ZK_LIST)
    end
  end

  def checks
    fail CanCan::AccessDenied, t('.check_lots_exists') unless current_user.plan_lots.exists?

    error_lots = current_user.plan_lots.invalid_okved.map(&:full_num)
    error_lots << current_user.plan_lots.invalid_sme.map(&:full_num)
    fail CanCan::AccessDenied, t(".not_valid", lots: error_lots.uniq.join('<br />')) unless error_lots.flatten!.empty?

    check_lots_for_group_operation # in ApplicationController

    rfa_sd = PlanLotStatus::REQUIRED_FOR_ACTION[:new_protocol_sd]
    rfa_zk = PlanLotStatus::REQUIRED_FOR_ACTION[:new_protocol_zk]

    statuses, text = @protocol.sd? ? [rfa_sd, t('.check_sd')] : [rfa_zk, t('.check_zk')]

    fail CanCan::AccessDenied, text if current_user.exists_plan_lots_with_another_statuses?(statuses)
  end

  def protocol_filter_params
    params[:protocol_filter]&.permit!
  end

  def protocol_params
    params.require(:protocol).permit(
      :gkpz_year, :protocol_type, :commission_id, :date_confirm, :format_id, :location, :num,
      protocol_files_attributes: [
        :note, :protocol_id, :tender_file_id, :id, :_destroy
      ],
      discuss_plan_lots_attributes: [
        :id, :status_id, :state, :tender_type_id
      ],
      merge_ids: [],
      plan_lot_ids: []
    )
  end
end
