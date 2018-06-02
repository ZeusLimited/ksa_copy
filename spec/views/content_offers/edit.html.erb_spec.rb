require 'spec_helper'

describe "content_offers/edit" do
  before(:each) do
    @content_offer = create(:content_offer, name: "MyText",
                                            num: "MyString",
                                            position: 1,
                                            content_offer_type_id: 1)
  end

  it "renders the edit content_offer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", content_offer_path(@content_offer), "post" do
      assert_select "textarea#content_offer_name[name=?]", "content_offer[name]"
      assert_select "input#content_offer_num[name=?]", "content_offer[num]"
      assert_select "input#content_offer_position[name=?]", "content_offer[position]"
      assert_select "input#content_offer_content_offer_type_id[name=?]", "content_offer[content_offer_type_id]"
    end
  end
end
