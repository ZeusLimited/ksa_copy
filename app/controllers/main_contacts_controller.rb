class MainContactsController < ApplicationController
  authorize_resource

  def index
    users = User.joins(:main_contact)
                .as_json(methods: [:fio_full, :phone])
    redux_store('SharedReduxStore', props: { contacts: MainContact.all, users: users })
  end

  def new
    @main_contact = MainContact.new
  end

  def create
    @main_contact = MainContact.create(main_contacts_params)
    if @main_contact.save
      redirect_to main_contacts_path
    else
      render 'new'
    end
  end

  def destroy
    @main_contact = MainContact.find(params[:id])
    @main_contact.destroy
    render json: @main_contact
  end

  def sort
    params[:data].each_with_index do |id, index|
      MainContact.find(id).update(position: index)
    end
    head :ok
  end

  private

  def main_contacts_params
    params.require(:main_contact).permit(:role, :user_id).merge(position: MainContact.maximum(:position).to_i + 1)
  end
end
