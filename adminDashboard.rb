get "/adminDashboard" do
  @user_error = nil

#-- Return user to login screen if account is not of type staff or isnt logged in at all
  logged_in = session["logged_in"]
  redirect "/login" if !logged_in

  user_id = session[:user_id]
  redirect "/login" if user_id == "customer"

  # calculate the top reader from the table 

  highest_read = 0

  User.all.each do |user| 
    leaderboard_username = user.user_name
    books_read = Reading.where(reader: leaderboard_username).count

    if books_read > highest_read then
      @top_reader = leaderboard_username
      @highest_read = books_read
    end
  end


  # calculate top writer from the table 

  highest_written = 0

  User.all.each do |user| 
    leaderboard_username = user.user_name
    books_written = Story.where(author: leaderboard_username).count

    if books_written > highest_written then
      @top_writer = leaderboard_username
      @highest_written = books_written
    end
  end


  # calculate top subscribed accounts from the table 

  highest_subscribed = 0

  User.all.each do |user|
    leaderboard_username = user.user_name
    subscriber_count = Subscription.where(subscribed_account: leaderboard_username).count
        
    if subscriber_count > highest_subscribed then
      @top_subscribed = leaderboard_username
      @highest_subscribed = subscriber_count
    end
  end

  erb :adminDashboard
end

post "/add_popcorn" do

  # admins can manually add popcorn to the user given

  @winner_user = (params[:winner_user]).strip
  @winner_popcorn = (params[:winner_popcorn]).to_i

  winner_user = User.first(user_name: @winner_user)
  popcorn_start = winner_user.popcorn
  popcorn_finished = popcorn_start + @winner_popcorn
  winner_user.popcorn = popcorn_finished
  winner_user.save_changes
  
  redirect "/adminDashboard" 
end