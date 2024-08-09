require "rspec"
RSpec.describe "Admin Dashboard View"
    describe "GET /adminDashboard" do
        it "Load Check: Status 302 OR 200" do
            get "/adminDashboard"
            expect(last_response.status).to eq(302)
        end
    end
    describe "POST /adminDashboard" do
        context "user is not logged in" do 
            it "redirects to /login" do
                visit "/adminDashboard"
                expect(page).to have_current_path("/login")
        end
    end
    describe "GET /adminDashboard" do
        context "user is logged in as admin" do
            it "displays adminDashboard" do
                visit "/login"
                fill_in "username", with: "admin"
                fill_in "password", with: "admin1!"
                click_on "Log In"

                visit "/adminDashboard"
                expect(page).to have_current_path("/adminDashboard")
            end
        end
    end
end
