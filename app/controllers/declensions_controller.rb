class DeclensionsController < ApplicationController
  authorize_resource

  before_action :load_content

  layout false, only: [:edit]

  def create
    @declension = @content.build_declension(declension_params)

    respond_to do |format|
      if @declension.save
        format.html { redirect_to @content, notice: "Declension created." }
        format.js { render nothing: true }
      else
        format.html { render "edit" }
        format.js { render status: 500 }
      end
    end
  end

  def edit
    @declension = @content.declension.presence || @content.build_declension
  end

  def update
    @declension = @content.declension

    respond_to do |format|
      if @declension.update_attributes(declension_params)
        format.html { redirect_to @content, notice: 'declension was successfully updated.' }
        format.js { render nothing: true }
      else
        format.html { render "edit" }
        format.js { render status: 500 }
      end
    end
  end

  private

  # def load_commentable
  #   resource, id = request.path.split('/')[1, 2]
  #   @commentable = resource.singularize.classify.constantize.find(id)
  # end

  def load_content
    klass = [Dictionary, Commission, LocalTimeZone].find { |c| params["#{c.name.underscore}_id"] }
    @content = klass.find(params["#{klass.name.underscore}_id"])
  end

  def declension_params
    params.require(:declension).permit(:content_id, :content_type, :name_d, :name_p, :name_r, :name_t, :name_v)
  end
end
