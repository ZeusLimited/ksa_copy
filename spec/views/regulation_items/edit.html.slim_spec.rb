require 'spec_helper'

RSpec.describe "regulation_items/edit", type: :view do
  let(:regulation_item) { create(:regulation_item) }
  let(:user) { create(:user_user) }
  before(:each) do
    sign_in user
    assign(:regulation_item, regulation_item)
  end

  it "renders the edit regulation_item form" do
    render

    assert_select "form[action=?][method=?]", regulation_item_path(regulation_item), "post" do

      assert_select "input#regulation_item_num[name=?]", "regulation_item[num]"

      assert_select "textarea#regulation_item_name[name=?]", "regulation_item[name]"

      assert_select "select#regulation_item_is_actual[name=?]", "regulation_item[is_actual]"
    end
  end
end
