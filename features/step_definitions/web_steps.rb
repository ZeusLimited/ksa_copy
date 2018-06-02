Given /^I have a plan_lot \(([^"]*)\) in my plan lots bag$/ do |trait|
  @current_user.plan_lots = [FactoryGirl.create(:plan_lot, trait.to_sym)]
end

When /^I select "([^"]*)" from invisible "([^"]*)"$/ do |value, element|
  find("##{element}", visible: false).set(value)
end

Then /^the element "([^"]*)" should has css class "([^"]*)"$/ do |element, class_name|
  page.should have_css("##{element}.#{class_name}")
end

Then /^the element "([^"]*)" should not has css class "([^"]*)"$/ do |element, class_name|
  page.should have_no_css("##{element}.#{class_name}")
end

Then /^the report "([^"]*)" should be "([^"]*)"$/ do |report, class_name|
  page.should have_css("li.#{class_name} a", :text => "#{report}")
end

Then /^I should get a download with filename "([^"]*)" from popup$/ do |filename|
  new_window = windows.last
  page.within_window new_window do
    steps %Q{
      Then I should get a download with filename "#{filename}"
    }
  end
end
