module Account
  module ProfileHelper
    def description_list_field(object, field)
      val = object.send(field)
      return unless val
      content_tag :dl, class: 'dl-horizontal' do
        concat content_tag :dt, object.class.human_attribute_name(field)
        concat content_tag :dd, val
      end
    end
  end
end
