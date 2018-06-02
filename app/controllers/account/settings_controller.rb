module Account
  class SettingsController < ApplicationController
    before_action :set_setting, except: :show

    USER_SETTINGS = %w[subscribe_send_time].freeze

    def show
      @settings = USER_SETTINGS.map do |setting|
        Setting.find_or_initialize_by user_setting_params.merge(var: setting)
      end
    end

    def edit; end

    def update
      if @setting.value != account_settings_params[:value]
        @setting.value = account_settings_params[:value]
        @setting.save
        redirect_to account_settings_path, notice: t('.notice')
      else
        redirect_to account_settings_path, alert: t('.alert')
      end
    end

    private

    def set_setting
      @setting = current_user.settings.find_by(find_params) ||
                 current_user.settings.new(user_setting_params.merge(find_params))
    end

    def account_settings_params
      params.require(:rails_settings_scoped_settings).permit(:value)
    end

    def find_params
      { var: params[:id] }
    end

    def user_setting_params
      {
        thing_id: current_user.id,
        thing_type: 'User',
      }
    end
  end
end
