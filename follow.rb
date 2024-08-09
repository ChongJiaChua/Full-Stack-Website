get "/profile_others" do
  query = params["user_name"] 
  session["visited_profile"] = query
  @user = User.where(user_name: query)

  @subscriber_count = Subscription.get_followers_count(query)
  @subscription_count = Subscription.get_followings_count(query)

  @is_subscribed = !Subscription[subscriber: session["user"], subscribed_account: query].nil?

  current_user = session["user"]
  @current_user = User.first(user_name: current_user)

  @stories = Story.where(author: session["visited_profile"])

  @is_admin = true if  !@current_user.nil? && @current_user.account_type == "admin"
  erb :profile_others
end

post "/profile_others" do
  action = params["action"]
  if !session["user"].nil?
    subscriber = session["user"]
    subscribed_account = params["subscribed_account"]

    if action == "follow"
      if Subscription[subscriber: subscriber, subscribed_account: subscribed_account].nil?
        Subscription.insert(subscriber: subscriber, subscribed_account: subscribed_account)
      end
    elsif action == "unfollow"
      Subscription.where(subscriber: subscriber, subscribed_account: subscribed_account).delete
    end
    redirect "/profile_others?user_name=#{subscribed_account}"

  else
    redirect '/login'
  end
end

get "/view_followers" do
  @user = session["user"]
  @followers = Subscription.retrieve_followers(@user)
  erb :view_followers

end

get "/view_following" do
  @user = session["user"]
  @followings = Subscription.retrieve_followings(@user)
  erb :view_following
end

post "/delete_account" do
  user = User.where(user_name: session["visited_profile"]).first
  user.delete
  redirect '/'

end

post "/add_popcorns" do
  @account = session["visited_profile"]
  viewed_account = User.first(user_name: @account)
  current_popcorn = viewed_account.popcorn

  values_to_be_added = params["addition"]
  
  new_amount = current_popcorn.to_i + values_to_be_added.to_i
  viewed_account.popcorn = new_amount
  viewed_account.save_changes

  redirect "/profile_others?user_name=#{@account}"
end

post "/set_account_type" do
  account_type = params["account_type"]

  visited_account = retrieve_visited_profile(session["visited_profile"])
  visited_account.account_type = account_type
  visited_account.save_changes

  redirect_current_page(session["visited_profile"])
end

def retrieve_visited_profile(session)
  return User.first(user_name: session)
end

def redirect_current_page(account) 
  redirect "/profile_others?user_name=#{account}"
end