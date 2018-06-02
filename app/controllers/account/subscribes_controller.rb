module Account
  class SubscribesController < ApplicationController
    before_action :set_form, only: [:new_list, :edit_list]
    before_action :set_subscribes, only: [:edit_list, :update_list, :delete_list]
    before_action :session_subscribes, only: [:index, :push_to_session, :pop_from_session]

    def index
      @subscribes = current_user.subscribes.order('created_at desc')
    end

    def new_list
      @subscribes = Subscribe.generate_list(current_user)
    end

    def create_list
      @subscribes = Subscribe.generate_list(current_user)

      save(@subscribes)
    end

    def edit_list; end

    def update_list
      save(@subscribes)
    end

    def delete_list
      @subscribes.delete_all
      session_subscribes.clear

      redirect_to account_subscribes_url, notice: t('.notice')
    end

    def push_to_session
      session[:subscribe_ids] += params[:subscribe_ids]
      head :ok
    end

    def pop_from_session
      session[:subscribe_ids] -= params[:subscribe_ids]
      head :ok
    end

    private

    def set_form
      @subscribe_form = SubscribeForm.new
    end

    def set_subscribes
      @subscribes = Subscribe.where(id: session[:subscribe_ids])
      fail CanCan::AccessDenied, t('.empty_collection') if @subscribes.empty?
    end

    def session_subscribes
      session[:subscribe_ids] ||= []
    end

    def save(subscribes)
      Subscribe.transaction { subscribes.each { |s| s.clear_update(account_sibscribes_params) } }

      redirect_to account_subscribes_url, notice: t('.notice')
    end

    def account_sibscribes_params
      params.require(:account_subscribe_form).permit(:theme, subscribe_actions_attributes: [:action_id, :_destroy],
                                                     subscribe_warnings_attributes: [:action_id, :days_before])
    end
  end
end
