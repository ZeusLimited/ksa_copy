module ApplicationHelper
  class HTMLwithPygments < Redcarpet::Render::HTML
    def table(header, body)
      "<table class=\"table table-nonfluid table-bordered table-striped\">" \
      "<thead>#{header}</thead><tbody>#{body}</tbody></table>"
    end
  end

  # TODO remove after fix bug https://github.com/rails/rails/issues/1769
  # rails 5.0
  def fix_url_singular_resource(record)
    { action: (record.new_record? ? 'create' : 'update') }
  end

  def text_plus(text)
    content_tag(:i, '', class: 'icon-plus') + ' ' + text
  end

  def text_minus(text)
    content_tag(:i, '', class: 'icon-minus') + ' ' + text
  end

  def plus_default_classes
    'btn btn-success pull-right input-large'
  end

  def minus_default_classes
    'btn btn-danger pull-right input-large'
  end

  def code_highlight_file(filename, lang)
    content_tag :div, CodeRay.scan(render(file: filename), lang).div.html_safe, class: 'code-highlight'
  end

  def markdown(text)
    renderer = HTMLwithPygments.new(hard_wrap: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true,
      tables: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end

  # def markdown(text)
  #   renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
  #   markdown = Redcarpet::Markdown.new(renderer, autolink: true, space_after_headers: true, tables: true)
  #   markdown.render(text).html_safe
  # end

  def general_title
    title = Setting.app_name
    part_name = I18n.t("controller_titles.#{controller_name}", raise: I18n::MissingTranslationData)
    part_name.empty? ? title : "#{title} - #{part_name}"
  rescue I18n::MissingTranslationData
    title
  end

  def t_enums(translate_key)
    t(translate_key).invert
  end

  def link_to_declension(content)
    link_to content_tag(:i, '', class: 'icon-th-list'),
            '#',
            class: 'declension',
            data: { url: url_for([:edit, content, :declension]), toggle: 'modal' },
            title: 'Просклонять'
  end

  def link_to_add_fields(name,
                         f,
                         association,
                         attr_class = "add_assoc_fields btn btn-success pull-right input-large",
                         link_id = nil,
                         locals: {})
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      locals = locals.merge(f: builder)
      render partial: association.to_s.singularize + "_fields", locals: locals
    end

    link_to(name, '#', id: link_id, class: attr_class, data: { id: id, fields: fields.gsub("\n", "") })
  end

  def abbr(abbr_short, abbr_full)
    content_tag(:abbr, abbr_short, title: abbr_full)
  end

  def short_text(text, length = 85)
    return unless text
    text.length > length ? content_tag(:abbr, truncate(text, length: length), title: text) : text
  end

  def bold_words(text, fragment)
    if fragment
      words = fragment.strip.split(/[\s,]+/)
      words.each { |w| text.gsub!(/(#{Regexp.escape(w)})/i, '<strong>\1</strong>') }
    end

    sanitize text, tags: %w(strong)
  end

  def link_to_history_icon(object)
    link_icon_title 'icon-eye-open',
                    'Иcтория изменений',
                    '#history',
                    class: 'history_link',
                    data: { item: object.class.name, id: object.id, toggle: "modal" }
  end

  def link_to_back_or_default(body, default_url = root_url, html_options = {})
    if request.env["HTTP_REFERER"].present? && request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      link_to body, :back, html_options
    else
      link_to body, default_url, html_options
    end
  end

  def link_to_session_or_default(body, session_variable, default_url = root_url, html_options = {})
    if session[session_variable] && session[session_variable] != request.env["REQUEST_URI"]
      link_to body, session[session_variable], html_options
    else
      link_to body, default_url, html_options
    end
  end

  def url_from_session_or_default(session_variable, default_url = root_url)
    if session[session_variable] && session[session_variable] != request.env["REQUEST_URI"]
      session[session_variable]
    else
      default_url
    end
  end

  def icon_for_tender_file(tender_file, size = '32px')
    ext = tender_file.document.file.extension.downcase

    icon_file = case ext
                when 'docx', 'doc' then 'doc.png'
                when 'rtf' then 'rtf.png'
                when 'xlsx', 'xls' then 'xls.png'
                when 'pdf' then 'pdf.png'
                when 'jpg', 'jpeg' then 'jpg.png'
                when 'tif', 'tiff' then 'tiff.png'
                when 'rar' then 'rar.png'
                when 'zip' then 'zip.png'
                when 'txt' then 'txt.png'
                else '_blank.png'
                end

    image_tag File.join('file-icons', size, icon_file)
  end

  def view_text_field(div_class, record, attribute, value = nil, text_options = {})
    view_text_element(:text_field, div_class, record, attribute, value, text_options)
  end

  def view_text_area(div_class, record, attribute, value = nil, text_options = {})
    view_text_element(:text_area, div_class, record, attribute, value, text_options)
  end

  def view_text_element(element, div_class, record, attribute, value = nil, text_options = {})
    content_tag(:div, class: div_class) do
      val = value ? value : record.send(attribute)
      text_options[:readonly] = true
      text_options[:id] = nil
      text_options[:class] = [text_options[:class], 'input-block-level'].compact.join(' ')
      hint = text_options.delete(:hint)
      label = text_options[:label] || record.class.human_attribute_name(attribute)
      concat label_tag(nil, label)
      concat text_area_tag(nil, val, text_options) if element == :text_area
      concat text_field_tag(nil, val, text_options) if element == :text_field
      concat hint
    end
  end

  def supported_browser?
    # Google Chrome
    # Apple Safari 6.0+
    # Mozilla Firefox 4.0+
    # Opera 12.0+
    # Microsoft Internet Explorer 10.0+
    result = true
    result = false if browser.safari? && browser.version.to_i < 6
    result = false if browser.firefox? && browser.version.to_i < 4
    result = false if browser.opera? && browser.version.to_i < 12
    result = false if browser.ie?(["<10"])
    result
  end

  def if_browser_is_supported(&block)
    supported_browser? ? capture(&block) : render("shared/supported_browser")
  end

  def gen_index
    "#{Time.now.to_i}#{Time.now.usec}"
  end

  def error_messages_for(model)
    if model.errors.any?
      content_tag :div, id: "error_explanation", class: "alert alert-error" do
        concat "При заполнении вы допустили ошибки:"
        errs = content_tag :ul do
          model.errors.full_messages.map { |msg| content_tag :li, msg.html_safe }.join.html_safe
        end
        concat errs
      end
    end
  end

  def p_money(val, precision = 2)
    number_with_precision(val, precision: precision, delimiter: '&nbsp;'.html_safe)
  end

  def to_money_str(val, precision = 2)
    number_with_precision(val, precision: precision, delimiter: ' ')
  end

  def to_thousand(val)
    val / 1000.0 unless val.nil?
  end

  def xlsx_money(val)
    number_with_precision(val, precision: 2, delimiter: 160.chr(Encoding::UTF_8))
  end

  def timepicker_div(&block)
    content_tag :div, class: "input-append bootstrap-timepicker" do
      capture(&block) + content_tag(:span, content_tag(:i, nil, class: "icon-time"), class: "add-on")
    end
  end

  def my_menu_item(name = nil, path = "#", is_active = false)
    content_tag :li, class: is_active ? "active" : nil do
      link_to name, path
    end
  end

  def local_time_with_msk(date, time_zone)
    return if date.blank?
    msk = ActiveSupport::TimeZone[time_zone.time_zone].local_to_utc(date).in_time_zone('Moscow')
    v_time = "#{date.strftime('%R')} часов"
    v_zone = if time_zone.time_zone == 'Moscow'
               'московского'
             else
               "местного (#{time_zone.name_r}) (#{msk.strftime('%R')} московского)"
             end
    v_date = "времени #{date.strftime('%d.%m.%Y')} г."
    "#{v_time} #{v_zone} #{v_date}"
  end

  def link_icon_title(icon_class, title, options = nil, html_options = {})
    name = content_tag(:i, nil, class: icon_class)
    html_options.merge!('data-toggle' => 'tooltip', title: title)
    link_to name, options, html_options
  end

  def link_icon_title_if(condition, icon_class, title, options = nil, html_options = {})
    name = content_tag(:i, nil, class: icon_class)
    html_options.merge!('data-toggle' => 'tooltip', title: title)
    link_to_if condition, name, options, html_options
  end

  def link_show(link_path)
    link_icon_title 'icon-info-sign', 'Просмотр', link_path
  end

  def link_edit(link_path)
    link_icon_title 'icon-edit', 'Редактировать', link_path
  end

  def link_delete(link_path)
    link_icon_title 'icon-trash', 'Удалить', link_path, method: :delete, data: { confirm: 'Вы уверены?' }
  end

  def tbool(b)
    if b.nil?
      nil
    else
      b ? "Да" : "Нет"
    end
  end

  def input_block_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: InputBlockFormBuilder)), &block)
  end

  def multi
    { data: { placeholder: 'Все' }, multiple: true }
  end

  def report_right_cell_class(type, style)
    types = %i(date time float integer boolean)
    styles = %i(td_right)
    styles.include?(style) || types.include?(type) ? 'right-cell' : nil
  end

  def report_value_with_format(value, type, style)
    return nil if value.nil?
    percent_styles = %i(td_percent sum_percent)
    val = value
    if type == :float
      val = percent_styles.include?(style) ? number_to_percentage(val * 100.0) : p_money(val)
    end
    val = val.try(:to_s, :default) if type == :date
    val
  end

  def rep_link(num, rep_class)
    path = url_for(controller: extract_rep_controller_name(rep_class), action: 'options')
    a = content_tag :a, "#{num}. #{rep_class.model_name.human}", class: 'rep-options', data: { url: path }
    content_tag :li, a
  end

  def rep_prd(rep_class, company = nil)
    return if company != nil && Setting.company != company

    path = format '/%s', legal_filename(extract_rep_controller_name(rep_class))
    html = <<-HTML
      <div class="alert alert-danger">
        <strong>Внимание!</strong>
        <span>Техническое задание к отчёту</span>
        <a href="%{path}" target="_blank">скачать</a>
      </div>
    HTML
    format(html, path: path).html_safe
  end

  def legal_filename(filename)
    dir = Dir[Rails.root.join('public')]
    legal_name = filename + "_#{Setting.company}" + '.pdf'
    return legal_name if File.exists?(File.join(dir, legal_name))
    filename + '.pdf'
  end

  def docx_template_exist?(template_name)
    template_path = File.join([Rails.configuration.docx_templates_path, template_name])
    File.exist?(template_path)
  end

  def sortable_column(column, title = nil, session_params)
    title ||= t(".#{column}")
    key, session_values = session_params.first
    link_to  content_tag(:span, "#{title} ") + content_tag(:i, '', class: "#{sort_icon(column, session_values)}"),
      params: { key => sort_params(column, session_values.dup) }
  end

  private

  def sort_params(column, params)
    params[:sort_column] =  column
    params[:sort_direction] = next_sort_direction(params[:sort_direction])
    params
  end

  def sort_icon(column, params)
    return '' unless params[:sort_column] == column
    params[:sort_direction] == 'asc' ? 'icon-chevron-up' : 'icon-chevron-down'
  end

  def next_sort_direction(sort_direction)
    sort_direction == 'asc' ? 'desc' : 'asc'
  end

  def extract_rep_controller_name(rep_class)
    rep_class.to_s.underscore
  end
end
