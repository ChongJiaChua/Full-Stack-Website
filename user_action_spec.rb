RSpec.describe User do
  before(:each) do
    visit '/login'
    fill_in 'username', with: 'user'
    fill_in 'password', with: 'user1!'
    click_on 'Log In'
  end

  describe "follow other acount" do
    context "when customer is logged in" do
      it "can follow other accounts" do
        user_name = "admin"
        visit "profile_others?user_name=#{user_name}"
        click_button "Follow"

        expect(Subscription.first(subscriber: "user").subscribed_account).to eq(user_name)
      end
    end
  end

  describe "unfollow other acccount" do
    context "when customer is logged in" do
      it "can unfollow other account" do
        user_name = "user2"
        visit "profile_others?user_name=#{user_name}"
        click_button "Unfollow"

        expect(Subscription.first(subscriber: "user")).to be_nil
      end
    end
  end

  describe "follow other account when not logged in" do
    context "when the user is not logged in" do
      it "redirects to login page" do
        click_button "Logout"
        user_name = "user2"
        visit "profile_others?user_name=#{user_name}"
        click_button "Follow"

        expect(page).to have_current_path("/login") 
      end
    end
  end

  describe "search for stories" do
    it "shows the list of available stories" do
      visit "/"
      select 'Stories', from: 'search-type'
      click_button 'Search'

      expect(page).to have_content('test')
    end
  end

  describe "search for users" do
    it "shows the list of available user" do
      visit "/"
      select "Users", from: "search-type"
      click_button 'Search'

      expect(page).to have_content("user2")
    end
  end


  

end