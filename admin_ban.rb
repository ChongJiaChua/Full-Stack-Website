get "/admin_ban" do

  @form_was_submitted = !params.empty?
  @submission_error = false
  redirect "/login" unless session["logged_in"]
  erb :admin_ban

end


post "/admin_ban" do
  redirect "/login" unless session["logged_in"]

  @username = params[:username].strip
  ban_reason = params[:ban_reason].strip 
  proceed = true

  errors = {}

  banneduser = Banneduser.new #create a new banned user in the table with this username
  banneduser.banned_user = @username

  banneduser.save_changes

  if banneduser.save
    redirect "/adminDashboard"
  else
    @submission_error = true
    erb :admin_ban, locals: {error_message: "Failed to update settings.", errors: errors}
  end
end