class ExpertOpinionsController < ApplicationController
  authorize_resource class: false

  def index
    @tender = Tender.find(params[:tender_id])
    @experts = @tender.experts.joins(:user).order("surname || ' ' || name || ' ' || patronymic")
  end

  def show_draft
    @tender = Tender.find(params[:tender_id])
    @offer = Offer.find params[:id]
    @expert = Expert.find params[:expert_id]
  end

  def edit_draft
    @tender = Tender.find(params[:tender_id])
    @offer = Offer.find params[:id]
    @expert = Expert.current(@tender, current_user).first
    destinations = @expert.destinations.map(&:ref_id)

    @opinions = @offer.draft_opinions.where(expert_id: @expert.id)
    @tender.tender_draft_criterions.current(destinations).each do |draft|
      unless @opinions.where(criterion_id: draft.id).first
        @offer.draft_opinions.build(expert_id: @expert.id, criterion_id: draft.id)
      end
    end
  end

  def update_draft
    @draft_opinion = DraftOpinion.get_or_new(ajax_params[:criterion_id], ajax_params[:expert_id], params[:id])
    @draft_opinion.vote = ajax_params[:vote]
    @draft_opinion.description = ajax_params[:description]
    @draft_opinion.save!
    head :ok
  end

  private

  def expert_opinion_params
    params.require(:offer).permit(
      draft_opinions_attributes: [:offer_id, :expert_id, :criterion_id, :vote, :description]
    )
  end

  def ajax_params
    params.require(:draft_opinion).permit(:offer_id, :expert_id, :criterion_id, :vote, :description)
  end
end
