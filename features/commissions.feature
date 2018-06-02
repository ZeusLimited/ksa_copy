Feature: commissions
  As a worker of purchases department
  I want to create commissions

  Scenario: Show field for_ customers
    Given I logged in as user
      And I am on the commissions page
     When I press "commissions_search_button"
      And I follow "Новая комиссия"
     Then I should be on the new commission page
      And I should not see a field "commission_for_customers"

  Scenario: Show link Export to Excel per lots
    Given I logged in as boss
      And I am on the commissions page
     When I press "commissions_search_button"
      And I follow "Новая комиссия"
     Then I should be on the new commission page
      And I should see a field "commission_for_customers"
