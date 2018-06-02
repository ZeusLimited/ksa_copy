class ApplicationController < ActionController::Base
  include Constants
  include OpenxmlDocxTemplater::Generator
  include ActionView::Helpers::NumberHelper
  include OrdersCheck
  include ReactOnRails::Controller
  protect_from_forgery

  NOT_AUTHORIZE_CONTROLLERS = %w(web_service docs registration_companies)

  ZIP_FILES_ZONE = File.join("uploads", "ZIP")

  before_action :authenticate_user!, unless: proc { |c| NOT_AUTHORIZE_CONTROLLERS.include?(c.controller_name) }
  before_action :log_user

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :restrict_ip
  before_action :set_paper_trail_whodunnit
  before_action :set_raven_context

  check_authorization unless: :do_not_check_authorization?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to url_to_back_or_default, alert: exception.message
    # render text: exception.message
  end

  private

  def restrict_ip
    return if ['172.30.47.193','62.33.64.93','95.213.247.39'].exclude?(request.host)
    html = <<-HTML
      <h1 align='center'>Доступ к системе по IP адресу запрещен!</h1>
    HTML
    render html: html.html_safe
  end

  def log_user
    logger.info "  Username: #{current_user.login}" if current_user
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer
      .permit(:sign_up,
              keys: [:email, :surname, :name, :patronymic, :user_job, :phone_public, :phone_cell, :phone_office,
                     :gender, :fax, :department_id, :root_dept_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:password, :password_confirmation, :current_password])
  end

  def do_not_check_authorization?
    respond_to?(:devise_controller?) ||
    params[:controller] == "markitup/rails/preview"
  end

  def url_to_back_or_default(default = root_url)
    if request.env["HTTP_REFERER"].present? && request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      url_for request.env["HTTP_REFERER"]
    else
      url_for default
    end
  end

  def url_to_session_or_default(session_variable, default = root_url)
    if session[session_variable] && session[session_variable] != request.env["REQUEST_URI"]
      session[session_variable]
    else
      url_for default
    end
  end

  def check_lots_for_group_operation
    if current_user.plan_lots.count('distinct root_customer_id') > 1
      customers = current_user.plan_lots.joins(:root_customer).uniq.pluck(:name).join(', ')
      fail CanCan::AccessDenied, "Нельзя делать групповую операцию с лотами разных заказчиков! (#{customers})"
    end
  end

  def check_selected_plan_lots_before_order
    array_lots = current_user.plan_lots
    fail CanCan::AccessDenied, t('check_selected_plan_lots.empty') if array_lots.empty?
    org_ids = array_lots.map { |l| Department.find(l.department_id).root_id }
    fail CanCan::AccessDenied, t('check_selected_plan_lots.org_diff') unless org_ids.uniq.size == 1
  end

  def check_selected_plan_lots
    array_lots = current_user.plan_lots
    fail CanCan::AccessDenied, t('check_selected_plan_lots.empty') if array_lots.empty?
    if Dictionary.types_for_public(array_lots.map(&:tender_type_id).uniq).empty?
      fail CanCan::AccessDenied, t('check_selected_plan_lots.type_diff')
    end
    unless (array_lots.map(&:status_id).uniq - PlanLotStatus::AGREEMENT_LIST).empty?
      fail CanCan::AccessDenied, t('check_selected_plan_lots.status')
    end
    unless array_lots.all?(&:can_execute_from_preselection?)
      fail CanCan::AccessDenied, t('check_selected_plan_lots.cannot_execute_from_preselection')
    end
    org_ids = array_lots.map { |l| Department.find(l.department_id).root_id }
    fail CanCan::AccessDenied, t('check_selected_plan_lots.org_diff') unless org_ids.uniq.size == 1
    fail CanCan::AccessDenied, t('check_selected_plan_lots.cannot_execute') unless array_lots.all?(&:can_execute?)
    check_lots_for_orders(array_lots)
  end

  def generate_document(template_name)
    template = File.join([Rails.configuration.docx_templates_path, template_name])
    output = "/tmp/#{template_name}_#{Time.current.to_s(:number)}.docx"
    render_msword template, output
    send_file output, type: :docx, disposition: 'attachment'
    File.delay_for(15.minutes, retry: 1).delete(output)
  end

  def compress_and_send_files(collection_files, file_name)
    zip_file = File.join(ZIP_FILES_ZONE, file_name + '.zip')
    zip_file_fullpath = File.join('.', 'public', zip_file)

    File.delay_for(3.days, retry: 1).delete(zip_file_fullpath) unless File.exist?(zip_file_fullpath)

    Zip::File.open(zip_file_fullpath, Zip::File::CREATE) do |zipfile|
      collection_files.each do |file|
        next if zipfile.find_entry(file.read_attribute(:document).b)
        zipfile.add(file.read_attribute(:document), file.document.file.file).compression_method = 0
      end
    end

    # Remove after update rubyzip to 1.2.0 version
    File.chmod(0644, zip_file_fullpath)

    redirect_to "/" + zip_file
  end

  def set_raven_context
    Raven.user_context(login: current_user.login) if current_user # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
