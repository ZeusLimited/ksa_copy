# require "spec_helper"

# feature "Протоколы выбора победителя" do

#   before(:each) do
#     user = create(:user_admin)
#     login_as(user, scope: :user)
#     contractor = create(:contractor)
#     status = create(:dictionary, :offer_status, ref_id: Constants::OfferStatuses::WIN)
#     @lot1 = create(:lot, offers: [create(:offer, bidder: create(:bidder, contractor: contractor), status: status)])
#     @lot2 = create(:lot, offers: [create(:offer, bidder: create(:bidder, contractor: contractor), status: status)])
#     @lot3 = create(:lot, offers: [create(:offer, bidder: create(:bidder, contractor: contractor), status: status)])
#     @tender = create(:tender, lots: [@lot1, @lot2, @lot3])
#   end

#   scenario "Просмотр протокола" do
#     wp = create(:winner_protocol,
#                 tender: @tender,
#                 winner_protocol_lots: [create(:winner_protocol_lot, lot: @lot1),
#                                        create(:winner_protocol_lot, lot: @lot2)])
#     visit tender_winner_protocol_path(@tender, wp)

#     expect(page).to have_content @lot1.name
#     expect(page).to have_content @lot2.name
#   end

#   scenario "Создание протокола" do
#     visit tender_winner_protocols_path(@tender)
#     click_link "Создать протокол"

#     within("form") do
#       fill_in 'winner_protocol_num', with: '123'
#       fill_in 'winner_protocol_confirm_date', with: '20.02.2014'
#       fill_in 'winner_protocol_vote_date', with: '14.02.2014'
#       check "winner_protocol_winner_protocol_lots_attributes_0_enable"
#       check "winner_protocol_winner_protocol_lots_attributes_1_enable"
#     end

#     click_button('Сохранить')

#     expect(page).to have_content 'Протокол выбора победителя успешно создан.'
#   end

#   scenario "Редактирование протокола" do
#     wp = create(:winner_protocol,
#                 tender: @tender,
#                 winner_protocol_lots: [create(:winner_protocol_lot, lot: @lot1),
#                                        create(:winner_protocol_lot, lot: @lot2)])
#     visit edit_tender_winner_protocol_path(@tender, wp)

#     within("form") do
#       fill_in 'winner_protocol_num', with: '123'
#       fill_in 'winner_protocol_confirm_date', with: '20.02.2014'
#       fill_in 'winner_protocol_vote_date', with: '14.02.2014'
#       uncheck "winner_protocol_lot_ids_#{@lot1.id}"
#       check "winner_protocol_lot_ids_#{@lot2.id}"
#       check "winner_protocol_lot_ids_#{@lot3.id}"
#     end

#     click_button('Сохранить')

#     expect(page).to have_content 'Протокол выбора победителя успешно изменён.'
#   end

#   scenario "Удаление протокола" do
#     wp = FactoryGirl.create(:winner_protocol, tender: @tender, lots: [@lot1, @lot2])
#     page.driver.submit :delete, tender_winner_protocol_path(@tender, wp), {}
#     expect(page).to have_content 'Протокол выбора победителя успешно удалён.'
#   end

# end
