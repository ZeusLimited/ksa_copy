require "spec_helper"

feature "Протоколы рассмотрения" do

  # before(:each) do
  #   user = create(:user_admin)
  #   login_as(user, scope: :user)
  #   @tender = create(:tender)
  #   @lot1 = create(:lot, tender: @tender)
  #   @lot2 = create(:lot, tender: @tender)
  #   @lot3 = create(:lot, tender: @tender)
  # end

  # scenario "Просмотр протокола" do
  #   rp = create(
  #     :review_protocol,
  #     tender: @tender,
  #     review_lots: [create(:review_lot, lot: @lot1), create(:review_lot, lot: @lot2)])
  #   visit tender_review_protocol_path(@tender, rp)

  #   expect(page).to have_content @lot1.name
  #   expect(page).to have_content @lot2.name
  # end

  # scenario "Создание протокола" do
  #   visit tender_review_protocols_path(@tender)
  #   click_link "Создать протокол"

  #   within("form") do
  #     fill_in 'review_protocol_num', with: '123'
  #     fill_in 'review_protocol_confirm_date', with: '20.02.2014'
  #     fill_in 'review_protocol_vote_date', with: '20.02.2014'
  #     check "review_protocol_review_lots_attributes_0_enable"
  #     check "review_protocol_review_lots_attributes_1_enable"
  #     fill_in "review_protocol_review_lots_attributes_0_compound_rebid_date_attributes_date", with: '25.02.2014'
  #     fill_in "review_protocol_review_lots_attributes_1_compound_rebid_date_attributes_date", with: '25.02.2014'
  #     fill_in "review_protocol_review_lots_attributes_0_rebid_place", with: 'Moscow'
  #     fill_in "review_protocol_review_lots_attributes_1_rebid_place", with: 'Moscow'
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'Протокол рассмотрения успешно создан.'
  # end

  # scenario "Редактирование протокола" do
  #   rp = create(
  #     :review_protocol,
  #     tender: @tender,
  #     review_lots: [create(:review_lot, lot: @lot1), create(:review_lot, lot: @lot2)])
  #   visit edit_tender_review_protocol_path(@tender, rp)

  #   within("form") do
  #     fill_in 'review_protocol_num', with: '123'
  #     fill_in 'review_protocol_confirm_date', with: '20.02.2014'
  #     fill_in 'review_protocol_vote_date', with: '20.02.2014'
  #     uncheck "review_protocol_review_lots_attributes_0_enable"
  #     check "review_protocol_review_lots_attributes_1_enable"
  #     check "review_protocol_review_lots_attributes_2_enable"
  #     fill_in "review_protocol_review_lots_attributes_1_compound_rebid_date_attributes_date", with: '25.02.2014'
  #     fill_in "review_protocol_review_lots_attributes_2_compound_rebid_date_attributes_date", with: '25.02.2014'
  #     fill_in "review_protocol_review_lots_attributes_1_rebid_place", with: 'Moscow'
  #     fill_in "review_protocol_review_lots_attributes_2_rebid_place", with: 'Moscow'
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'Протокол рассмотрения успешно изменён.'
  # end

  # scenario "Удаление протокола" do
  #   rp = create(
  #     :review_protocol,
  #     tender: @tender,
  #     review_lots: [create(:review_lot, lot: @lot1), create(:review_lot, lot: @lot2)])
  #   page.driver.submit :delete, tender_review_protocol_path(@tender, rp), {}
  #   expect(page).to have_content 'Протокол рассмотрения успешно удалён.'
  # end

end
