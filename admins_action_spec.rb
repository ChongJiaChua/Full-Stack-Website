RSpec.describe User do
  before(:each) do
    visit '/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'admin1!'
    click_on 'Log In'
  end

  describe 'delete account' do
    context 'when admin is logged_in' do
      it 'he will be able to delete an account' do
        user_name_to_delete = "user2"
        visit "profile_others?user_name=#{user_name_to_delete}"
        click_button "Delete Account"


        expect(User.where(user_name: user_name_to_delete)).to be_empty
      end
    end
  end

  describe 'add popcorns' do
    context 'when admins is logged in' do
      it "can add popcorn to the customers" do
        user_name_to_add = "user"
        visit "profile_others?user_name=#{user_name_to_add}"
        fill_in "Popcorn amount to be added", with: "500"
        click_button "Add Popcorns"

        expect(User.first(user_name: user_name_to_add).popcorn).to eq(600)
      end
    end
  end

  describe 'change account type' do
    context 'when admin is logged in' do
      it 'can change the user account type' do
        user_name_to_change = "user"
        visit "profile_others?user_name=#{user_name_to_change}"
        choose "Management"
        click_button "Set"
        expect(User.first(user_name: user_name_to_change).account_type).to eq("management")
      end
    end
  end

  describe 'delete story' do
    context 'when admin is logged in' do
      it 'can delete the the stories' do
        story_id = 0
        visit "reading_page?id=#{story_id}"
        click_button "Delete Story"
        expect(Story.where(story_id: story_id)).to be_empty
      end
    end
  end

  describe 'set free stories' do
    context 'when admin is logged in' do
      it 'can set stories to free' do
        story_id = 0
        visit "reading_page?id=#{story_id}"
        click_button "Set Free"
        expect(Story.first(story_id: story_id).cost).to eq(0)
      end
    end
  end
  

  describe "reset free stories" do
    context "when admin is logged in" do
      it "can reset the stories back to the original price" do
        story_id = 0
        visit "reading_page?id=#{story_id}"
        click_button "Set Free"
        click_button "Reset Free"
        expect(Story.first(story_id: story_id).cost).to eq(20)

      end
    end
  end

  describe "admins add new words to censor" do
    it "adds a new words to be censored" do
      text = "shit"
      visit "reading_page?id=#{0}"
      fill_in "Add new filter word here", with: "shit"
      click_button "Add words"
      expect(!CensoredWords.first(word: text).nil?).to eq(!nil)
    end
  end
  
end