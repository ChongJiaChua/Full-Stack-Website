require "rspec"


RSpec.describe "Login View" do
    describe "GET /login" do
        it "Load Check: Status 200" do
            get "/login"
            expect(last_response.status).to eq(200)
        end
    end

    describe "POST /register" do
        context "with incorrect register details" do 
            it "tells user details are incorrect" do
                post "/register", "newUsername" => "user234", "newEmail" => "user@", "newPassword" => "pass"
                expect(last_response).to be_ok
                expect(last_response.body).to include("Password is too short.")
                expect(last_response.body).to include("Username cannot contain a number.")
                expect(last_response.body).to include("Password does not contain a number.")
                expect(last_response.body).to include("Password does not contain a special character.")
                expect(last_response.body).to include("Invalid Email.")
            end
        end

        context "with correct register details" do 
            it "redirects to homepage" do
                post "/register", "newUsername" => "useruser", "newEmail" => "user@email.com", "newPassword" => "user1!"
                expect(last_response).to be_redirect
            end
        end
    end

    describe "POST /login" do
        context "with incorrect login details" do 
            it "tells user details are incorrect" do
                post "/login", "username" => "us747", "password" => "doop"
                expect(last_response).to be_ok
                expect(last_response.body).to include("Username or Password is incorrect. Please try again.")
            end
        end

        context "with correct login details" do 
            it "redirects to homepage" do
                post "/login", "username" => "user", "password" => "user1!"
                expect(last_response.status).to eq(302) # redirects to homepage
            end
            it "checks login method" do
                user = User.first(user_name: "user")
                user.setIv(user.iv)
                user.setSalt(user.salt)
                user.setDataCrypt(user.password)
                returnValue = user.login({"password" => "user1!"})
                expect(returnValue).to eq(true)
            end
        end

        context "month difference less than one" do
          it "does not update popcorn balance" do
            post "/login", "last_update_date" => "2024-04-26", "current_date" => "2024-04-26"
            expect(last_response).to be_ok
          end
        end

        context "month difference more or equal than one" do
          it "adds 10 to the users popcorn balance" do
            post "/login", "last_update_date" => "2024-04-26", "current_date" => "2024-05-27"
            expect(last_response).to be_ok
          end
        end

    end
end
        


