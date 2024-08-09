require "rspec"

RSpec.describe "Writing View" do

  before(:all) do
    # Disable foreign key constraints
    DB.execute("PRAGMA foreign_keys = OFF;")

  end

  after(:all) do
    # Re-enable foreign key constraints
    DB.execute("PRAGMA foreign_keys = ON;")

  end


    describe "GET /writing" do
      it "loads the writing page and returns status 200" do
        session = { "user" => "user", "logged_in" => true }  # Mock session indicating user is logged in
        get "/writing", {}, { "rack.session" => session }
  
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Write Story")
      end
  
      it "redirects to login if the user isn't logged in" do
        session = { "logged_in" => false }
        get "/writing", {}, { "rack.session" => session }
  
        expect(last_response.status).to eq(302)  # Redirect status
        expect(last_response.location).to include("/login")
      end
    end

    describe "POST /sendStory" do
        context "correct info" do 
            it "directs back to the home page" do
                session = { "user" => "user", "logged_in" => true }
                post "/sendStory", {"title" => "testTitle",  "genres" => "Adventure", "price" => 20, "story_content" => "fjkdsfbsjdfb", "language" => "English"}, {"rack.session" => session}
                expect(page).to have_current_path("/")
            end
        end
    end
end