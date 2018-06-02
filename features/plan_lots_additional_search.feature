@javascript
Feature: Additional Search in plan_lots
  As a worker of purchases department
  I want to able to searching with additional params

  Background:
    Given I have logged in as user
      And I am on the plan_lots page
     Then the element "plan_lots_additional_search" should not has css class "in"

  Scenario: Initiate Additional Search
    When I click on "Расширенный поиск"
    Then the element "plan_lots_additional_search" should has css class "in"

  Scenario: Using Additional Search
    When I click on "Расширенный поиск"
     And I select "2017" from invisible "plan_filter_years"
     And I fill in "plan_filter_start_cost" with "50000"
     And I press "plan_lot_search_button"
    Then the element "plan_lots_additional_search" should has css class "in"

