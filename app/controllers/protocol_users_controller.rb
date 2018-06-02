class ProtocolUsersController < ApplicationController
  # GET /protocol_users
  # GET /protocol_users.json
  def index
    @protocol_users = ProtocolUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @protocol_users }
    end
  end

  # GET /protocol_users/1
  # GET /protocol_users/1.json
  def show
    @protocol_user = ProtocolUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @protocol_user }
    end
  end

  # GET /protocol_users/new
  # GET /protocol_users/new.json
  def new
    @protocol_user = ProtocolUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @protocol_user }
    end
  end

  # GET /protocol_users/1/edit
  def edit
    @protocol_user = ProtocolUser.find(params[:id])
  end

  # POST /protocol_users
  # POST /protocol_users.json
  def create
    @protocol_user = ProtocolUser.new(protocol_user_params)

    respond_to do |format|
      if @protocol_user.save
        format.html { redirect_to @protocol_user, notice: 'Protocol user was successfully created.' }
        format.json { render json: @protocol_user, status: :created, location: @protocol_user }
      else
        format.html { render "new" }
        format.json { render json: @protocol_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /protocol_users/1
  # PUT /protocol_users/1.json
  def update
    @protocol_user = ProtocolUser.find(params[:id])

    respond_to do |format|
      if @protocol_user.update_attributes(protocol_user_params)
        format.html { redirect_to @protocol_user, notice: 'Protocol user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @protocol_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protocol_users/1
  # DELETE /protocol_users/1.json
  def destroy
    @protocol_user = ProtocolUser.find(params[:id])
    @protocol_user.destroy

    respond_to do |format|
      format.html { redirect_to protocol_users_url }
      format.json { head :no_content }
    end
  end

  private

  def protocol_user_params
    params.require(:protocol_user).permit(:commission_id, :is_veto, :status, :user_id)
  end
end
