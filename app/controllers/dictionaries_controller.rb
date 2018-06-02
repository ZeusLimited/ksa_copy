class DictionariesController < ApplicationController
  authorize_resource

  # GET /dictionaries
  # GET /dictionaries.json
  def index
    session[:filter_dic_path] = request.env["REQUEST_URI"]

    @types = [
      ['Способы закупок', 'Tender_Types'],
      ['Виды закупаемой продукции', 'Product_Types'],
      ['Предметы закупкок', 'Subject_Types'],
      ['Статусы членов комиссии', 'Commissioner'],
      ['Статусы лота в планировании', 'PlanLotStatus'],
      ['Статусы лота в исполнении', 'Lot_Status'],
      ['Типы закупочных комиссий', 'Commission_Types'],
      ['Источники финансирования', 'Financing_Sources'],
      ['Типы документов ГКПЗ', 'PlanLotFileType'],
      ['Типы документов в регламенте', 'TenderFileType'],
      ['Адреса ЭТП', 'Etp_Addresses'],
      ['Значения НДС', 'NDS'],
      ['Документы определяющие цену', 'CostDoc'],
      ['Типы инвестиционных проектов', 'InvestProjectType'],
      ['Типы требований к составу заявок', 'ContentOfferType'],
      ['Направления оценки предложения', 'Destinations'],
      ['Формы проведения протоколов утверждения', 'Format_Meeting'],
      ['Решения протоколов ВП', 'WinnerProtocolSolutionTypes']
    ]

    params[:ref_type] = @types[0][1] unless params[:ref_type].present?
    @dictionaries = Dictionary.search(params)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dictionaries }
    end
  end

  def reduction
    @tender_types = Dictionary.tender_types.order(:position)
    @product_types = Dictionary.product_types.order(:position)
    @directions = Direction.order(:position)
    @commission_types = Dictionary.commission_types.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dictionaries }
    end
  end

  # GET /dictionaries/1
  # GET /dictionaries/1.json
  def show
    @dictionary = Dictionary.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dictionary }
    end
  end

  # GET /dictionaries/new
  # GET /dictionaries/new.json
  def new
    @dictionary = Dictionary.new(ref_type: params[:ref_type])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dictionary }
    end
  end

  # GET /dictionaries/1/edit
  def edit
    @dictionary = Dictionary.find(params[:id])
  end

  # POST /dictionaries
  # POST /dictionaries.json
  def create
    @dictionary = Dictionary.new(dictionary_params)
    @dictionary.generate_ref_id

    respond_to do |format|
      if @dictionary.save
        format.html { redirect_to url_to_session_or_default(:filter_dic_path, dictionaries_url), notice: 'Значение справочника успешно создано.' }
        format.json { render json: @dictionary, status: :created, location: @dictionary }
      else
        format.html { render "new" }
        format.json { render json: @dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dictionaries/1
  # PUT /dictionaries/1.json
  def update
    @dictionary = Dictionary.find(params[:id])

    respond_to do |format|
      if @dictionary.update_attributes(dictionary_params)
        format.html { redirect_to url_to_session_or_default(:filter_dic_path, dictionaries_url), notice: 'Значение справочника успешно обновлено.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dictionaries/1
  # DELETE /dictionaries/1.json
  def destroy
    @dictionary = Dictionary.find(params[:id])
    @dictionary.destroy

    respond_to do |format|
      format.html { redirect_to url_to_session_or_default(:filter_dic_path, dictionaries_url) }
      format.json { head :no_content }
    end
  end

  def order1352_reg_item
    @order1352 = Dictionary.order1352.order1352_special(params[:regulation_item])
    render json: @order1352
  end

  private

  def dictionary_params
    params.require(:dictionary).permit(
      :fullname, :is_actual, :name, :ref_id, :ref_type, :position, :stylename_docx, :stylename_html, :stylename_xlsx,
      :color
    )
  end
end
