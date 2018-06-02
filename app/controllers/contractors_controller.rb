# frozen_string_literal: true

require 'savon'

class ContractorsController < ApplicationController
  before_action :set_ability_to_edit_all, only: [:new, :create, :edit, :update]
  before_action :set_contractor, only: [:show, :edit, :update, :destroy, :change_status, :tenders]
  before_action :check_edit, only: [:edit, :update]
  before_action :check_delete, only: [:destroy]
  before_action :check_change_status, only: [:change_status]

  authorize_resource

  def index
    @contractors = Contractor.search(search_params)
    respond_to do |format|
      format.json
      format.html do
        @contractors = @contractors.page params[:page]
        session[:filter_contractors] = contractors_url(search_params)
      end
    end
  end

  def show; end

  def new
    @contractor = Contractor.new(form: "company")
  end

  def edit; end

  def create
    @contractor = current_user.contractors.build(contractor_params)

    respond_to do |format|
      if @contractor.save
        format.html { redirect_to @contractor, notice: t('.notice') }
        format.json { render json: @contractor.as_json(except: :guid, methods: :guid_hex), status: :created }
      else
        format.html { render :new }
        format.json { render json: @contractor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @contractor.user = current_user

    if @contractor.update(contractor_params)
      redirect_to @contractor, notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @contractor.destroy
    redirect_to url_to_session_or_default(:filter_contractors, contractors_url)
  end

  def search
    @contractors = Contractor.contractor_names(params[:term]).not_olds.active
    render :results
  end

  def search_potential_bidders
    @contractors = Contractor.potential_bidders(params[:term])
    render :results
  end

  def search_bidders
    @contractors = Contractor.bidders(params[:term], params[:tender_type_id].to_i)
    render :results
  end

  def search_reports
    @contractors = Contractor.contractor_names(params[:term])
    render :results
  end

  def search_parents
    @contractors = Contractor.parent_contractors(params[:term], params[:inn])
    render :results
  end

  def info
    @contractors = Contractor.where(id: params[:id].try(:split, ',')).order(:fullname)
    render json: @contractors.as_json(except: :guid, methods: :name_long)
  end

  def change_status
    case params[:status]
    when 'active'
      status = 1
      msg = t('.actual')
    when 'inactive'
      status = 3
      msg = t('.inactive')
    when 'orig'
      status = 0
      msg = t('.new')
    end
    @contractor.update_attribute('status', status)
    redirect_to @contractor, notice: msg
  end

  def tenders
    @tenders = Tender.for_contractor(params[:id], current_user).page(params[:page]).per(10)
  end

  def find_by_inn
    @contractor = Contractor.by_inn(params[:inn], params[:kpp]).first
    render json: @contractor.as_json(methods: [:guid_hex], except: :guid)
  end

  private

  def set_ability_to_edit_all
    gon.cannot_edit_all = current_user.cannot?(:contractor_boss, Contractor)
  end

  def set_contractor
    @contractor = Contractor.find(params[:id])
  end

  def check_edit
    fail CanCan::AccessDenied unless @contractor.can_edit?(current_user)
  end

  def check_delete
    fail CanCan::AccessDenied unless @contractor.can_delete?(current_user)
  end

  def check_change_status
    fail CanCan::AccessDenied unless @contractor.can_change_status?(current_user)
  end

  def search_params
    params.permit(:q)
  end

  def contractor_params
    params.require(:contractor).permit(
      :name, :fullname, :inn, :kpp, :ogrn, :okpo, :form, :jsc_form_id, :legal_addr, :is_resident,
      :is_dzo, :is_sme, :sme_type_id, :oktmo, :reg_date, :ownership_id, :parent_id,
      files_attributes: [:id, :_destroy, :tender_file_id, :file_type_id, :note])
  end
end
