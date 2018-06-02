require "spec_helper"

describe "shared/_declension" do
  it "renders a modal dialog" do
    render
    assert_select "div.modal div.modal-body"
  end
end
