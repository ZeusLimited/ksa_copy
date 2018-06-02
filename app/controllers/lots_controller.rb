class LotsController < ApplicationController
  load_and_authorize_resource :tender
  load_and_authorize_resource through: :tender

  decorates_assigned :tender, :lot

  def frame_info; end

end
