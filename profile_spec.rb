RSpec.describe User do
  before(:all) do
    # Disable foreign key constraints
    DB.execute("PRAGMA foreign_keys = OFF;")

  end

  after(:all) do
    # Re-enable foreign key constraints
    DB.execute("PRAGMA foreign_keys = ON;")

  end

  describe "User when user is logged in" do
    it "renders the profile page" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value

      get '/profile', {}, { 'rack.session' => session }

      expect(last_response.status).to eq(200) #Expect the profile page to render
    end
  end

  describe "GET /profile" do
      context "when user is not logged in" do
          it "redirects to /login" do
            
            #visit the profile page without logging in
            visit "/profile" 
            expect(page).to have_current_path("/login") #redirect to /login 

          end
      end
  end

  describe "GET /view_followers" do
    context "when the user is logged in" do
      it "loads the view_followers page" do

        session = { "user" => "user", "logged_in" => true } #Assert the session value

        get '/view_followers', {}, { 'rack.session' => session }
  
        expect(last_response.status).to eq(200) #Expect the profile page to render
      end
    end
  end

  describe ""

  describe "GET /view_following" do
    context "when the user is logged in" do
      it "loads the view_following page" do

        session = { "user" => "user", "logged_in" => true } #Assert the session value

        get '/view_following', {}, { 'rack.session' => session }
  
        expect(last_response.status).to eq(200) #Expect the profile page to render
      end
    end
  end

  describe "GET /wishlist" do
    context "when the user is logged_in" do
      it "loads the wishlist page" do

        session = { "user" => "user", "logged_in" => true } #Assert the session value

        get '/wishlist', {}, { 'rack.session' => session }
  
        expect(last_response.status).to eq(200) #Expect the profile page to render
      end
    end
  end

  describe "GET /view_subscriptions" do
    context "when the user is logged in" do
      it "shows the view subscriptions page" do
        session = { "user" => "user", "logged_in" => true } #Assert the session value

        get '/view_subscriptions', {}, { 'rack.session' => session }
        expect(last_response.status).to eq(200) #Expect the profile page to render
      end
    end
  end

  describe "GET /liked_stories" do
    context "when the user is logged in" do
      it "loads the liked_stories page" do
        session = { "user" => "user", "logged_in" => true } #Assert the session value

        get '/liked_stories', {}, { 'rack.session' => session }
        expect(last_response.status).to eq(200) #Expect the profile page to render
      end
    end
  end


end