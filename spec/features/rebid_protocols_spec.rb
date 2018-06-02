require "spec_helper"

feature "Протоколы переторжки" do

  before(:each) do
    user = FactoryGirl.create(:user_admin)
    login_as(user, scope: :user)
    @commission = create(:commission_with_users, :level1_kk)
    @new_commission = create(:commission_with_users, :level2_kk, department: @commission.department)
    @tender = create(:tender_with_lots, department: @commission.department, commission: @commission)
    Lot.change_status(@tender.lots, Constants::LotStatus::NEW, Constants::LotStatus::REVIEW_CONFIRM)
  end

  # scenario "Просмотр протокола" do
  #   rp = FactoryGirl.create(:rebid_protocol, tender: @tender)
  #   @tender.lots.first.rebid_protocol_id = rp.id

  #   visit tender_rebid_protocol_path(@tender, rp)

  #   expect(page).to have_content @tender.lots.first.name
  # end

  # scenario "Создание протокола", js: true do
  #   visit tender_rebid_protocols_path(@tender)

  #   click_link "Создать протокол"

  #   within("form") do
  #     fill_in 'rebid_protocol_num', with: ''
  #     fill_in 'rebid_protocol_confirm_date', with: '20.02.2014'
  #     fill_in 'rebid_protocol_vote_date', with: '01.02.2014'
  #     fill_in 'rebid_protocol_confirm_city', with: 'Хабаровск'
  #     fill_in 'rebid_protocol_compound_rebid_date_attributes_date', with: '21.02.2014'
  #     fill_in 'rebid_protocol_compound_rebid_date_attributes_time', with: '12:40'
  #     fill_in 'rebid_protocol_location', with: 'Хабаровск'
  #     fill_in 'rebid_protocol_resolve', with: 'Утвердить протокол'
  #     check "rebid_protocol_rebid_protocol_present_members_attributes_0_enable"
  #     check "rebid_protocol_rebid_protocol_present_members_attributes_1_enable"
  #     check "rebid_protocol_rebid_lots_attributes_0_selected"
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'При заполнении вы допустили ошибки'

  #   within("form") do
  #     fill_in 'rebid_protocol_num', with: '123'
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'Протокол переторжки успешно создан.'
  # end

  # scenario "Редактирование протокола", js: true do
  #   rp = create(:rebid_protocol_with_members, tender: @tender, commission: @commission)
  #   visit edit_tender_rebid_protocol_path(@tender, rp)

  #   within("form") do
  #     fill_in 'rebid_protocol_num', with: '123'
  #     fill_in 'rebid_protocol_confirm_date', with: ''
  #     check "rebid_protocol_rebid_protocol_present_members_attributes_1_enable"
  #     check "rebid_protocol_rebid_protocol_present_members_attributes_2_enable"
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'При заполнении вы допустили ошибки'

  #   within("form") do
  #     fill_in 'rebid_protocol_confirm_date', with: '14.02.2014'
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'Протокол переторжки успешно изменён.'
  # end

  # scenario "Удаление протокола" do
  #   rp = create(:rebid_protocol, tender: @tender)
  #   page.driver.submit :delete, tender_rebid_protocol_path(@tender, rp), {}
  #   expect(page).to have_content 'Протокол переторжки успешно удалён.'
  # end

end
