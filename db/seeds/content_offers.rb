def create_content_offer_from_old(parent_id, level = '')
  puts "load content_offer for parent_id: #{parent_id}"
  filter = parent_id.nil? ? "parent_id is null" : "parent_id = #{parent_id}"
  sql = "SELECT * FROM confirm_docs@ksazd_old WHERE #{filter} ORDER BY position"
  User.connection.select_all(sql).each_with_index do |row, i|
    num = "#{level}#{i + 1}."
    ContentOffer.create(name: row["name"], num: num, content_offer_type_id: Constants::ContentOfferType::MTR)
    create_content_offer_from_old(row["id"], num)
  end
end

ContentOffer.delete_all

puts "load content offers"
create_content_offer_from_old(nil)
ContentOffer.reorder
