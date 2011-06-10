Feature: eat
  Scenario: Silly cucumber test
    Given the email queue is empty
    And all emails have been delivered
    When I GET to eat "a%20cookie"
    Then I should see "Put a cookie in fridge to eat later."
    When all queued jobs are processed
    Then 1 email should be delivered to "foo@bar.com"
    And the email should contain "a cookie"

  Scenario: Another test
    When I GET to eat "an%20apple"
    Then I should see "Put an apple in fridge to eat later."
    Then the most recent food in redis should be "an apple"
    And deleting it from the cache should succeed

