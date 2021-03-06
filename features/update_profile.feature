Feature Update a profile
  Background:
    Given I am logged in as mislav
      And I am on the account settings page

  Scenario: Mislav updates his profile
    Given I follow "Profile Information"
      And I should see "Your Profile Settings" within "h2"
     When I fill in the following:
         | First name        | Mis                      |
         | Last name         | Mar                      |
         | Biography         | Ruby Rockstar Programmer |
      And I press "Update account"
     Then I should see "User profile updated!" within ".flash_success div"
      And I follow "mislav" within ".global"
     Then I should see "Mis Mar" within ".banner h2"
      And I should see "Ruby Rockstar Programmer" within ".biography"

  Scenario: Mislav updates his profile picture
    Given I follow "Profile Picture"
      And I should see "Your Profile Picture" within "h2"
      And I attach the file at "features/support/sample_files/dragon.jpg" to "user_avatar"
      And I press "Update account"    
     Then I should not see missing avatar image within ".column"

  Scenario: Mislav fails to update his profile picture with blank
  Scenario: Mislav fails to update his profile picture because its too big
       
  Scenario: Mislav updates his notifications
  Given I follow "Notifications"
    And I should see "Your Notifications" within "h2"  
   When I check "user_notify_mentions"
   When I uncheck "user_notify_conversations"
   When I check "user_notify_task_lists"
   When I check "user_notify_tasks"
    And I press "Update account"
   Then I should see "User profile updated!" within ".flash_success div"
    And I follow "Notifications"
    And I should see "Your Notifications" within "h2"      
    And the "Notify me when I'm mentioned eg. Howdy @mislav! You'll recieve an email!" checkbox should be checked
    And the "Notify me when I'm watching a conversation" checkbox should not be checked
    And the "Notify me when I'm watching a task list" checkbox should be checked
    And the "Notify me when I'm watching a task" checkbox should be checked

  Scenario: Mislav updates his username
     Given I follow "Account Settings"
       And I should see "Your Account Settings" within "h2"  
      When I fill in "Username" with "mislavrocks"
       And I press "Update account"
      Then I should see "User profile updated!" within ".flash_success div"
       And I should see "mislavrocks" within ".global"
       
  Scenario: Mislav fails to update his username because its already in use
  Scenario: Mislav fails to update his username with invalid format
  Scenario: Mislav updates his profile information
  Scenario: Mislav fails to update his profile information  