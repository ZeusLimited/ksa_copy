class UserController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  authorize_resource

  def index
    @users = User.search(search_params[:q]).order('surname, name, patronymic')
    session[:filter_users] = user_index_url(search_params)
  end

  def show
    @user = User.find params[:id]
  end

  def edit; end

  def update
    need_send_user_approval = !@user.approved? && user_params[:approved] == '1'
    if @user.update_attributes(user_params)
      AdminMailer.user_approval(@user).deliver if need_send_user_approval
      redirect_to url_to_session_or_default(:filter_users, user_index_path), notice: t('.notice')
    else
      render :edit
    end
  end

  def search
    @users = User.user_names(params[:term]).limit(15)
    render json: @users.map { |u| { id: u.id, label: u.fullname, value: u.fullname } }
  end

  def info
    @users = User.where(id: params[:id].try(:split, ','))
  end

  def destroy
    @user.destroy
    redirect_to user_index_path, notice: t('.notice')
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to user_index_path, alert: t('.alert')
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def search_params
    params.permit(:q)
  end

  def user_params
    pars = params.require(:user).permit(
      :email, :password, :password_confirmation, :remember_me, :login, :department_id, :approved, :surname, :name,
      :patronymic, :user_job, :phone_public, :phone_cell, :phone_office, :fax, :gender,
      assignments_attributes: [:department_id, :user_id, :role_id, :_destroy, :id]
    )
    pars.delete(:password) if pars[:password].blank?
    pars.delete(:password_confirmation) if pars[:password].blank? and pars[:password_confirmation].blank?
    pars
  end
end
