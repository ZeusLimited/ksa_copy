class ExpertsController < ApplicationController
  load_and_authorize_resource :tender

  decorates_assigned :tender

  def index
    redux_store('SharedReduxStore', props: { experts: @tender.experts.for_index })
  end

  def edits
    @tender.experts.build if @tender.experts.size == 0
  end

  def updates
    if @tender.update_attributes(tender_params)
      redirect_to tender_experts_path, notice: t('.notice')
    else
      render "edits"
    end
  end

  private

  def tender_params
    params.require(:tender).permit(
      experts_attributes: [
        :tender_id, :user_id, :id, :_destroy, { destination_ids: [] }
      ]
    )
  end
end
