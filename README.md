# Predefined Username and Password
Username and password are not the same due to additional security requirements on the login page.
This is because encrypted passwords are required for the login and we cannot manually encrypt passwords to enter into the database.

|Account type|Username|Password|
|------------|--------|--------|
|Customer|user|user1!|
|Admin|admin|admin1!|
|Manager|manager|manager1!|

# Commands needed to Run and Test the Page
### Running website:
Assuming starting from fresh Codio terminal with repository loaded:
cd project/
bundle install
sinatra

### Testing website:
Assuming starting from fresh Codio terminal with repository loaded:
cd project/
rspec


### Key notes before using the website:
1) The username of a user cannot be changed in the settings
2) The field that have to be completed before you are able to change your details in settings are 
    - username
    - email
    - current password
    - new password
3) Free popcorns are given 1 month from the day the account was created
