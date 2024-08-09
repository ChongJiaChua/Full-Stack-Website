RSpec.describe User do


  describe 'User profile' do
    context 'when user is logged in' do
      it 'displays the user information' do
        # Simulate user login
        visit '/login'
        fill_in 'username', with: 'user'
        fill_in 'password', with: 'user1!'
        click_on 'Log In'
  
        # Access the profile page
        get '/profile', {}, { 'rack.session' => { logged_in: true, "user":"user"} }
  
        # Check if redirected to the profile page
        expect(last_response).to be_ok
        expect(last_request.path).to eq('/profile')
  
        # Check if the profile page contains the correct user information
        expect(last_response.body).to include("user")
        expect(last_response.body).to include("100")
        expect(last_response.body).to include("user@email.com")
        expect(last_response.body).to include("100.0")
      end
    end
  end
end