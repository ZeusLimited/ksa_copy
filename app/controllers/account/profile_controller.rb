module Account
  class ProfileController < ApplicationController

    def show; end

    def edit; end

    def update
      if current_user.update_attributes(account_profile_params)
        redirect_to account_profile_path
      else
        render :edit
      end
    end

    def from_ldap
      render json: current_user.info_from_ldap
    end

    def update_photo
      if current_user.update_photo_from_ldap
        redirect_to account_profile_path, notice: t('.notice')
      else
        redirect_to account_profile_path, alert: t('.alert')
      end
    end

    private

    def account_profile_params
      params.require(:user).permit(:login, :email, :surname, :name, :patronymic, :user_job, :phone_public, :phone_cell,
                                   :phone_office, :fax, :department_id)
    end
  end
end
