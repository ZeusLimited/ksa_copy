Feature: Execute Tenders with SingleSource tender type
  As a worker of purchases department
  I need to execute these types of procedure in simple mode

  Scenario: Prepare to execute
    Given I logged in as user
      And I am on the plan_lots page
      And I have a plan_lot (ttype_po) in my plan lots bag
    When I press "plan_lot_search_button"
    Then I should see the element "#new_single_source"

  Scenario: Execute
    Given I logged in as user
      And I am on the plan_lots page
      And I have a plan_lot (ttype_po) in my plan lots bag
      And I press "plan_lot_search_button"
    When I follow "new_single_source"
