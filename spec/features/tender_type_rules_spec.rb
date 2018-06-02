require "spec_helper"

feature "Правила смены статусов" do

  before(:each) do
    user = create(:user_admin)
    login_as(user, scope: :user)
  end

  scenario "Изменение правил" do
    visit tender_type_rules_path

    click_link 'Изменить правила'

    within("form") do
      within("#tender_type_list_rules_#{TenderTypes::OOK}_fact_type_ids") do
        find("option[value='#{TenderTypes::OOK}']").click
        find("option[value='#{TenderTypes::ZOK}']").click
      end
    end

    click_button('Сохранить')

    expect(page).to have_content 'Правила успешно изменены!'

  end
end
