require "spec_helper"

feature "Лоты" do

  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    login_as(@user, scope: :user)
    @lot1 = FactoryGirl.create(:lot)
    @lot2 = FactoryGirl.create(:lot)
    @tender = FactoryGirl.create(:tender, lots: [@lot1, @lot2])
  end

  scenario "Очистка корзины" do
    visit cart_lots_path

    click_link 'Очистить корзину'

    expect(page).to have_content "Корзина очищена!"
  end

  scenario "Удаление из корзины" do
    @user.lots << [@lot1]
    visit cart_lots_path

    click_link "Удалить из корзины"

    expect(page).to have_content 'Лот удален из корзины!'
  end

  scenario "Добавление в корзину" do
    page.driver.submit :post, cart_lots_path, lot_id: @lot2.id

    expect(page).to have_content @user.lots.count
  end
end
