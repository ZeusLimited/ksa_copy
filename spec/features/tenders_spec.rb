require "spec_helper"
include Constants

feature "Tender Filters" do
  before(:each) do
    user = create(:user_admin)
    login_as(user, scope: :user)
    @tender = create(:tender_with_lots)
  end

  scenario "Empty filters" do
    visit "/tenders"
    expect(page).not_to have_text("Найдено закупок:")
  end

  scenario "User creates a new widget" do
    visit "/tenders"
    click_button "Поиск"
    expect(page).to have_text("Найдено закупок:")
  end
end

feature "Create tender" do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    login_as(@user, scope: :user)
    @organizer = create(:department)
    @commission = create(:commission, :level1_kk, department: @organizer)
  end

  # scenario "create from plan" do
  #   plan_lots = create_list(:plan_lot_with_plan_specifications, 2,
  #                           tender_type_id: TenderTypes::ORK,
  #                           department: @organizer,
  #                           status: create(:dictionary, :plan_lot_status, ref_id: PlanLotStatus::CONFIRM_SD))
  #   plan_lot = create(:plan_lot, tender_type_id: TenderTypes::OA)
  #   @user.plan_lots << plan_lots
  #   @user.plan_lots << plan_lot

  #   visit new_tender_path

  #   expect(page).to have_text("Для данной группы лотов невозможно выбрать способ закупки согласно правилам")

  #   @user.clear_plan_lots
  #   plan_lot = create(:plan_lot,
  #                     tender_type_id: TenderTypes::ORK,
  #                     status: create(:dictionary, :plan_lot_status, ref_id: PlanLotStatus::NEW))

  #   @user.plan_lots << plan_lots
  #   @user.plan_lots << plan_lot

  #   visit new_tender_path

  #   expect(page).to have_text("Лоты должны быть согласованы или утверждены")

  #   @user.clear_plan_lots
  #   @user.plan_lots << plan_lots

  #   visit new_tender_path

  #   expect(page).to have_text("Создание закупочной процедуры")

  #   within('form') do
  #     fill_in "tender_num", with: '123'
  #     fill_in "tender_announce_date", with: '01.01.2014'
  #     fill_in "tender_compound_bid_date_attributes_date", with: ''
  #     fill_in "tender_compound_review_date_attributes_date", with: '15.03.2014'
  #     fill_in "tender_compound_summary_date_attributes_date", with: '25.03.2014'
  #     fill_in "tender_announce_place", with: 'Test'
  #     fill_in "tender_bid_place", with: 'Test'
  #     fill_in "tender_review_place", with: 'Test'
  #     fill_in "tender_summary_place", with: 'Test'
  #     fill_in "tender_lots_attributes_0_specifications_attributes_0_qty", with: '100'
  #     find("option[value='#{@commission.id}']").select_option
  #   end

  #   click_button("Сохранить")

  #   expect(page).to have_text("При заполнении вы допустили ошибки")

  #   within('form') do
  #     fill_in "tender_lots_attributes_0_specifications_attributes_0_qty", with: '1'
  #     fill_in "tender_compound_bid_date_attributes_date", with: '01.03.2014'
  #     find("#tender_lots_attributes_0_specifications_attributes_0_financing_id")
  #       .find("option[value='#{@financing.id}']").select_option
  #     find("#tender_lots_attributes_1_specifications_attributes_0_financing_id")
  #       .find("option[value='#{@financing.id}']").select_option
  #   end

  #   click_button("Сохранить")

  #   expect(page).to have_text("Закупочная процедура успешно создана.")
  # end

  # scenario "create from frame" do
  #   tender = create(:tender, lots: [build(:lot_with_spec, :contract)],
  #                            tender_type_id: Constants::TenderTypes::ORK, department: @organizer)
  #   @user.lots << tender.lots.first

  #   visit 'cart_lots'

  #   click_link 'Провести ЗЗЦ'

  #   expect(page).to have_text("Создание закрытого запроса цен по результатам рамки")

  #   within('form') do
  #     fill_in "tender_num", with: '123'
  #     fill_in "tender_announce_date", with: '01.01.2014'
  #     fill_in "tender_compound_bid_date_attributes_date", with: ''
  #     fill_in "tender_compound_review_date_attributes_date", with: '15.03.2014'
  #     fill_in "tender_compound_summary_date_attributes_date", with: '25.03.2014'
  #     fill_in "tender_announce_place", with: 'Test'
  #     fill_in "tender_bid_place", with: 'Test'
  #     fill_in "tender_review_place", with: 'Test'
  #     fill_in "tender_summary_place", with: 'Test'
  #     fill_in "tender_lots_attributes_0_specifications_attributes_0_qty", with: '100'
  #     fill_in "tender_lots_attributes_0_sublot_num", with: ''
  #     select @commission.commission_type_name, from: "Закупочная комиссия"
  #   end

  #   click_button("Сохранить")

  #   expect(page).to have_text("При заполнении вы допустили ошибки")

  #   within('form') do
  #     fill_in "tender_compound_bid_date_attributes_date", with: '01.03.2014'
  #     find("option[value='#{Financing::COST_PRICE}']").select_option
  #   end

  #   click_button("Сохранить")

  #   expect(page).to have_text("ЗЗЦ успешно создана.")
  # end

  # scenario "copy" do
  #   tender = FactoryGirl.create(:tender, lots: [FactoryGirl.create(:lot, future_plan_id: 1)], department: @organizer)

  #   visit "/tenders/#{tender.id}/copy"

  #   within('form') do
  #     find("#tender_lot_ids_#{tender.lots.first.id}").set(true)
  #   end

  #   click_button "Следующий шаг"

  #   expect(page).to have_text("Создание копии закупочной процедуры")

  #   within('form') do
  #     fill_in "tender_num", with: '123'
  #     fill_in "tender_announce_date", with: '01.01.2014'
  #     fill_in "tender_compound_bid_date_attributes_date", with: ''
  #     fill_in "tender_compound_review_date_attributes_date", with: '15.03.2014'
  #     fill_in "tender_compound_summary_date_attributes_date", with: '25.03.2014'
  #     fill_in "tender_announce_place", with: 'Test'
  #     fill_in "tender_bid_place", with: 'Test'
  #     fill_in "tender_review_place", with: 'Test'
  #     fill_in "tender_summary_place", with: 'Test'
  #     fill_in "tender_lots_attributes_0_specifications_attributes_0_qty", with: '100'
  #     find("option[value='#{@commission.id}']").select_option
  #   end

  #   click_button("Сохранить")

  #   expect(page).to have_text("При заполнении вы допустили ошибки")

  #   within('form') do
  #     fill_in "tender_compound_bid_date_attributes_date", with: '01.03.2014'
  #     find("option[value='#{@financing.ref_id}']").select_option
  #   end

  #   click_button("Сохранить")

  #   expect(page).to have_text("Копия успешно создана.")
  # end
end

feature "Change Status" do
  before(:each) do
    user = create(:user_admin)
    login_as(user, scope: :user)
    @tender = create(:tender_with_lots, open_protocol: build(:open_protocol))
  end

  scenario "Public" do
    visit tender_path(@tender)

    click_link 'Опубликовать'
    expect(page).to have_content "Закупка опубликована"
  end
end

feature "Tender offer requirements" do
  # before(:each) do
  #   user = FactoryGirl.create(:user_admin)
  #   login_as(user, scope: :user)
  #   @tender = FactoryGirl.create(:tender)
  # end

  # scenario "Show offer requirements" do
  #   visit "/tenders/#{@tender.id}/show_offer_requirements"
  #   expect(page).to have_text("Требования к заявкам")
  # end

  # scenario "Edit offer requirements", js: true do
  #   visit "/tenders/#{@tender.id}/edit_offer_requirements"

  #   expect(page).to have_text("Редактирование требований к заявкам")

  #   fill_in 'tender_prepare_offer', with: 'test'
  #   fill_in 'tender_offer_reception_start', with: '11.02.2014'
  #   fill_in 'tender_offer_reception_stop', with: '12.02.2014'
  #   fill_in 'tender_offer_reception_place', with: 'test'

  #   find('#add_tender_content_offer').click

  #   # save_and_open_page

  #   within('fieldset.tender_content_offers') do
  #     find("input[id$='_num']").set("123")
  #     find('.select_content_offer').click
  #   end
  # end
end
