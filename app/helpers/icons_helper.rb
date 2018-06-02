# frozen_string_literal: true

module IconsHelper
  def material_icon(name, size: 24, **options)
    image_tag(material_icon_path(name, size), options)
  end

  def material_icon_path(name, size = 24)
    image_path("material-icons/ic_#{name}_black_#{size}px.svg")
  end
end
