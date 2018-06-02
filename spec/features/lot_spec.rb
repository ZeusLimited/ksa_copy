require "spec_helper"

feature "Лоты" do

  before(:each) do
    user = FactoryGirl.create(:user_admin)
    login_as(user, scope: :user)
    @lot1 = FactoryGirl.create(:lot_with_spec)
    @lot2 = FactoryGirl.create(:lot_with_spec)
    @tender = FactoryGirl.create(:tender, lots: [@lot1, @lot2])
  end

  scenario "Просмотр договора" do
    visit contracts_tender_path(@tender)

    expect(page).to have_content "Список договоров"
  end

  # scenario "Создание планов на будущее" do
  #   visit contracts_tender_lots_path(@tender)
  #   click_link "Не привела к заключению договора"

  #   within("form") do
  #     find("option[value='#{@plan.ref_id}']").click
  #     fill_in 'lot_future_plan_note', with: '123'
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'Лот успешно изменен.'
  # end

  # scenario "Редактирование планов на будущее" do
  #   visit future_plan_contract_tender_lot_path(@tender, @lot1)

  #   within("form") do
  #     find("option[value='#{@plan.ref_id}']").click
  #     fill_in 'lot_future_plan_note', with: '123'
  #   end

  #   click_button('Сохранить')

  #   expect(page).to have_content 'Лот успешно изменен.'
  # end

  # scenario "Удаление планов на будущее" do
  #   visit contracts_tender_lots_path(@tender)
  #   click_link "Удалить"

  #   expect(page).to have_content 'Дальнейшие планы по закупке успешно удалены.'
  # end

end
