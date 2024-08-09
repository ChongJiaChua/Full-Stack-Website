RSpec.describe Story do

  describe "GET /genre_search" do
    it "loads the genre_search page" do
      get "/genre_search"

      expect(last_response.status).to eq(200)
    end
  end

  describe "search according to genre" do
    it "display stories with the according genre" do
      visit "/genre_search"
      select 'Adventure', from: 'name'
      click_button 'Search'
      expect(page).to have_content("test")
      expect(page).to have_content("Genre : Adventure")
    end
  end

  describe "search according to language" do
    it "display stories with the selected language" do
      visit "/genre_search"
      select "English", from: 'language'
      click_button "Search"
      expect(page).to have_content("test")
    end
  end
end