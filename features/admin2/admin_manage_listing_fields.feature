Feature: Admin adds a custom field

  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |
      | main           | Spaces            | Tilat          |
    And I am on the custom fields admin2 page
    Then I should see that I do not have any custom fields
    
