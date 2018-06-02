module EmailHelper
  def email_image_tag(image)
    file = Rails.root.join("app/assets/images/#{image}")
    ext = File.extname(file)
    attachments.inline[image] = {
      data: File.read(file),
      mime_type: "image/#{ext[1..-1]}"
    }
    image_tag attachments[image].url
  end
end
