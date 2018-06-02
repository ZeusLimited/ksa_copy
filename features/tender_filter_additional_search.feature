@javascript
Feature: tenders_filter
  I am worker department of purchase
  I am put on button additional search

  Background:
    Given I logged in as user
      And I am on the tenders page

  Scenario: Before click on the button additional_search
    Then the element "tenders_additional_search" should not has css class "in"

  Scenario: Click on the button additional_search
    When I click on "Расширенный поиск"
    Then the element "tenders_additional_search" should has css class "in"

  Scenario: Check class "in" if something typed on the additional field
    When I click on "Расширенный поиск"
     And I fill in "tender_filter_search_by_contract_nums" with '123'
    Then the element "tenders_additional_search" should has css class "in"
