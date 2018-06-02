class TendersController < ApplicationController
  include Constants
  include OrdersCheck
  load_and_authorize_resource param_method: :main_tender_params, except: :new
  skip_load_resource only: :index

  decorates_assigned :tender

  before_action :set_gon_commissions, only: [:new, :create, :new_from_copy, :create_from_copy,
                                             :edit, :update]

  def index
    @tender_filter = TenderFilter.new(tender_filter_params)
    @tenders = @tender_filter.search if tender_filter_params.present?

    respond_to do |format|
      format.json { }
      format.html do
        @tenders = @tenders&.page params[:page]
        session[:tenders_filter_path] = url_for(tender_filter_url_params)
      end
    end
  end

  def show
    respond_to do |format|
      format.html { render tender.show_template }
      format.json do
        render json: @tender.as_json(
          methods: [:user_email, :tender_type_name, :tender_type_fullname],
          include: {
            lots: {
              methods: [:guid_hex, :plan_lot_guid_hex],
              except: [:guid, :plan_lot_guid],
              include: { specifications: { methods: [:guid_hex], except: :guid } }
            },
            link_tender_files: {
                include: { tender_file: { only:
                  [:user_id], methods: [:filename, :valid_url]
                }
              }
            }
          }
        )
      end
    end
  end

  def new
    check_selected_plan_lots # ApplicationController
    @tender = Tender.build_from_plan_lots(current_user)
    @types = allow_types(current_user.plan_lots.pluck(:tender_type_id).uniq)
    @etp_addresses = allow_etps(current_user.plan_lots.pluck(:etp_address_id).uniq)
    authorize! :new, @tender
  end

  def create
    create_tender(Tender.generate_from_plan(main_tender_params), :new)
  end

  def new_from_copy
    check_array_tender_lots(Lot.where(id: copy_tender_params[:lot_ids]))
    @tender = Tender.build_from_tender_lots(current_user, copy_tender_params)
    plan_lots = PlanLot.joins(:lots).where(lots: { id: copy_tender_params[:lot_ids] })
    @types = allow_types(plan_lots.pluck(:tender_type_id).uniq)
    @etp_addresses = allow_etps(plan_lots.pluck(:etp_address_id).uniq)
    authorize! :new_from_copy, @tender
  end

  def create_from_copy
    create_tender(Tender.generate_from_copy(main_tender_params), :new_from_copy)
  end

  def new_from_frame
    check_array_lots_from_frame(current_user.lots)
    @tender = Tender.build_from_frame(current_user)
    source_etps = PlanLot.joins(:lots).where(lots: { id: @tender.lots.map(&:frame_id) }).pluck(:etp_address_id).uniq
    @types = allow_types(nil)
    @etp_addresses = allow_etps(source_etps)
    authorize! :new_from_frame, @tender
  end

  def create_from_frame
    create_tender(Tender.generate_from_frame(main_tender_params), :new_from_frame)
  end

  def copy; end

  def edit
    return redirect_to edit_unregulated_path(@tender) if @tender.unregulated?

    @types = allow_types(@tender.plan_lots.pluck(:tender_type_id).uniq)
    lots = @tender.plan_lots.present? ? @tender.plan_lots : @tender.plan_frame_lots
    @etp_addresses = allow_etps(lots.pluck(:etp_address_id).uniq)
  end

  def update
    if @tender.update_attributes(main_tender_params)
      respond_to do |format|
        format.html { redirect_to @tender, notice: t('.notice') }
        format.json { render :show }
      end
    else
      @types = allow_types(@tender.plan_lots.pluck(:tender_type_id).uniq)
      lots = @tender.plan_lots.present? ? @tender.plan_lots : @tender.plan_frame_lots
      @etp_addresses = allow_etps(lots.pluck(:etp_address_id).uniq)
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @tender.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tender.destroy

    redirect_to url_to_session_or_default(:tenders_filter_path, tenders_url)
  end

  def add_zzc
    fail CanCan::AccessDenied, t('exec_from_frame_info')
    check_array_lots_from_frame(current_user.lots, @tender)
    @tender.add_lots_from_frames(current_user.lots, @tender.lots.pluck(:num).max + 1)

    @tender.save(validate: false)
    redirect_to @tender, notice: t('.notice')
  end

  def show_bidder_requirements; end

  def edit_bidder_requirements; end

  def update_bidder_requirements
    if @tender.update_attributes(bidder_requirements_tender_params)
      redirect_to show_bidder_requirements_tender_path(@tender), notice: t('.notice')
    else
      render :edit_bidder_requirements
    end
  end

  def offers
    @lots = @tender.lots
    render :index_offers_for_opinion
  end

  def show_offer_requirements; end

  def edit_offer_requirements; end

  def update_offer_requirements
    if @tender.update_attributes(offer_requirements_tender_params)
      @tender.reorder_tender_eval_criterions
      @tender.reorder_tender_content_offers
      redirect_to show_offer_requirements_tender_path(@tender), notice: t('.notice')
    else
      render :edit_offer_requirements
    end
  end

  def public
    status_next = @tender.open_protocol ? LotStatus::OPEN : LotStatus::PUBLIC

    Lot.change_status(@tender.lots, LotStatus::NEW, status_next)

    redirect_to tender_path(@tender), notice: t('.notice')
  end

  def contracts; end

  def export_excel
    @tender_filter = TenderFilter.new(tender_filter_params)
    @tenders = @tender_filter.for_excell
    render xlsx: "tenders", disposition: "attachment", filename: "#{Time.current.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
  end

  def show_standard_form
    respond_to do |format|
      format.docx { generate_document(params[:template]) }
    end
  end

  def search_b2b_classifiers
    @classifiers = B2bClassifier.nodes_for_filter(params[:q])
    render json: @classifiers
  end

  def get_b2b_classifier
    @classifiers = B2bClassifier.where(classifier_id: params[:classifier_id].split(' '))
  end

  private

  def set_gon_commissions
    gon.commissions = Commission.actuals.execute_group.includes(:commission_type).map do |c|
      { dep_id: c.department_id, name: c.commission_type_name, id: c.id }
    end
  end

  def allow_types(source_types)
    return Dictionary.where(ref_id: TenderTypes::ZZC) unless source_types.present?
    Dictionary.types_for_public(source_types)
  end

  def allow_etps(source_etps)
    Dictionary.etp_for_public(source_etps)
  end

  def create_tender(tender, template)
    if tender.save
      redirect_to tender, notice: t('.notice')
    else
      @tender = tender
      @types = allow_types(PlanLot.where(id: @tender.lots.map(&:plan_lot_id)).pluck(:tender_type_id).uniq)
      @etp_addresses = allow_etps(PlanLot.where(id: @tender.lots.map(&:plan_lot_id)).pluck(:etp_address_id).uniq)
      render template
    end
  end

  def copy_tender_params
    params.require(:tender).permit(lot_ids: [])
  end

  def check_array_tender_lots(array_lots)
    fail CanCan::AccessDenied, t('.empty') if array_lots.empty?
    fail CanCan::AccessDenied, t('.invalid_lot') if array_lots.any? { |l| !l.can_copy? }
    fail CanCan::AccessDenied, t('.many_tender') unless array_lots.map(&:tender_id).uniq.size == 1
    check_lots_for_orders(array_lots)
  end

  def check_array_lots_from_frame(array_lots, tender = nil)
    fail CanCan::AccessDenied, t('.empty') if array_lots.empty?
    org_ids = array_lots.map { |l| Department.find(l.tender.department_id).root_id }
    if tender
      is_etp = array_lots.map(&:tender_etp_address_id).uniq.include?(EtpAddress::B2B_ENERGO)
      fail CanCan::AccessDenied, t('.invalid_etp') if tender.etp_address_id == EtpAddress::NOT_ETP && is_etp
      org_ids.push(tender.department.root_id).compact!
    end
    fail CanCan::AccessDenied, t('.org_diff') unless org_ids.uniq.size == 1
    fail CanCan::AccessDenied, t('.invalid_status') if array_lots.any? { |l| l.status_id != LotStatus::CONTRACT }
    fail CanCan::AccessDenied, t('.invalid_lot') if array_lots.any? { |l| l.tender_type_id != TenderTypes::ORK }
    check_lots_for_orders(array_lots)
  end

  def tender_filter_params
    @tender_filter_params ||= params[:tender_filter]&.merge(current_user: current_user)&.permit!
  end

  def tender_filter_url_params
    params.permit(:controller, :action).merge(tender_filter: tender_filter_params)
  end

  def main_tender_params
    params.require(:tender).permit(
      :tender_type_id,
      :etp_address_id,
      :department_id,
      :official_site_num,
      :what_valid,
      :from_what,
      :commission_id,
      :user_id,
      :local_time_zone_id,
      :num,
      :order_num,
      :order_date,
      :name,
      :announce_place,
      :bid_place,
      :review_place,
      :summary_place,
      :announce_date,
      :etp_num,
      :oos_num,
      :oos_id,
      :contract_period,
      :is_profitable,
      :contract_period_type,
      link_tender_files_attributes: [:id, :_destroy, :tender_id, :tender_file_id, :file_type_id, :note],
      compound_bid_date_attributes: [:date, :time],
      compound_review_date_attributes: [:date, :time],
      compound_summary_date_attributes: [:date, :time],
      lots_attributes: [:id, :num, :plan_lot_id, :prev_id, :name, :frame_id, :activity_id, :buisness_type_id,
                        :object_stage_id, :privacy_id, :is_adjustable_rate, :is_ensure_tenders, :non_public_reason,
                        :boss_note, :note, :not_lead_contract, :no_contract_next_bidder, :fas_appeal, :num_plan_eis,
                        :registred_bidders_count, :life_cycle, :_destroy, :sublot_num, :sme_type_id,
                        specifications_attributes: [:id, :plan_specification_id, :qty, :cost_money, :cost_nds_money,
                                                    :financing_id, :prev_id, :name, :_destroy, :frame_id]])
  end

  def bidder_requirements_tender_params
    params.require(:tender).permit(
      :provide_offer,
      :preferences,
      :is_sertification,
      tender_draft_criterions_attributes: [
        :name, :num, :id, :_destroy, { destination_ids: [] }
      ])
  end

  def offer_requirements_tender_params
    params.require(:tender).permit(
      :offer_reception_start,
      :offer_reception_stop,
      :offer_reception_place,
      :prepare_offer,
      :guarantie_date_begin,
      :guarantie_date_end,
      :guarantie_offer,
      :guarant_criterions,
      :guarantie_making_money,
      :guarantie_recvisits,
      :alternate_offer,
      :alternate_offer_aspects,
      :prepayment_cost_money,
      :prepayment_percent_money,
      :prepayment_period_begin,
      :prepayment_period_end,
      :prepayment_aspects,
      tender_content_offers_attributes: [
        :_destroy, :id, :num, :name, :content_offer_type_id
      ],
      tender_eval_criterions_attributes: [
        :_destroy, :id, :num, :name, :value
      ],
      lots_attributes: [
        :id, :guarantie_cost_money
      ])
  end
end
