class UserDecorator < Draper::Decorator
  delegate_all

  def roles_ru
    roles.map(&:name_ru).join('<br>')
  end

  def photo(klass = "img-polaroid")
    h.image_tag photo_url, class: klass, alt: "Фото"
  end

  def photo_url
    avatar_url || "noname_avatar.png"
  end
end
