Feature: plan_lots_export_excel
  As a worker of purchases department
  I want to export found lots to Excel

  Background:
    Given I logged in as user
      And I am on the plan lots page
     When I press "plan_lot_search_button"

  Scenario: Show link Export to Excel per lots
    Then I should see "Экспорт в Excel (по лотам)"


  Scenario: Click Export to Excel
    When I follow "export_excel"
    Then I should get a download with filename "plan_lots_(.*)xlsx"

  Scenario: Click link Export to Excel per lots
    When I follow "export_excel_lot"
    Then I should get a download with filename "plan_lots_(.*)xlsx"
