class InputBlockFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, options = {}, &block)
    options.merge! input_html: {} unless options.key?(:input_html)
    if options[:input_html].key?(:class)
      options[:input_html][:class] += ' input-block-level'
    else
      options[:input_html].merge! class: 'input-block-level'
    end
    super
  end
end
