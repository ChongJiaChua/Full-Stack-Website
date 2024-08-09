require "rspec"


RSpec.describe "Admin Settings View" do
  describe "GET /admin_settings" do
    it "Load Check: Status 200" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value
      get "/admin_settings", {}, {"rack.session" => session}
      expect(last_response.status).to eq(200)
    end
  end
end