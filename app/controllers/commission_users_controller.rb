class CommissionUsersController < ApplicationController
  # GET /commission_users
  # GET /commission_users.json
  def index
    @commission_users = CommissionUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @commission_users }
    end
  end

  # GET /commission_users/1
  # GET /commission_users/1.json
  def show
    @commission_user = CommissionUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @commission_user }
    end
  end

  # GET /commission_users/new
  # GET /commission_users/new.json
  def new
    @commission_user = CommissionUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @commission_user }
    end
  end

  # GET /commission_users/1/edit
  def edit
    @commission_user = CommissionUser.find(params[:id])
  end

  # POST /commission_users
  # POST /commission_users.json
  def create
    @commission_user = CommissionUser.new(commission_user_params)

    respond_to do |format|
      if @commission_user.save
        format.html { redirect_to @commission_user, notice: 'Commission user was successfully created.' }
        format.json { render json: @commission_user, status: :created, location: @commission_user }
      else
        format.html { render "new" }
        format.json { render json: @commission_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /commission_users/1
  # PUT /commission_users/1.json
  def update
    @commission_user = CommissionUser.find(params[:id])

    respond_to do |format|
      if @commission_user.update_attributes(commission_user_params)
        format.html { redirect_to @commission_user, notice: 'Commission user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @commission_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commission_users/1
  # DELETE /commission_users/1.json
  def destroy
    @commission_user = CommissionUser.find(params[:id])
    @commission_user.destroy

    respond_to do |format|
      format.html { redirect_to commission_users_url }
      format.json { head :no_content }
    end
  end

  private

  def commission_user_params
    params.require(:commission_user).permit(:commission_id, :is_veto, :status, :user_id, :user_name, :user_job, :status_name)
  end
end
