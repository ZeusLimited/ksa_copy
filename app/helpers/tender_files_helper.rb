module TenderFilesHelper
  def link_delete_tf_file(tender_file)
    return '' if current_user.id != tender_file.user_id && !current_user.has_role?(:moderator)

    link_to '#', class: 'btn btn-danger remove-files' do
      concat content_tag :i, '', class: 'icon-trash icon-white'
      concat content_tag :span, 'Удалить'
    end
  end
end
