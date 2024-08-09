get "/payment" do  

  @form_was_submitted = nil
  @submission_error = nil
  @login_error = nil
  @price_error = nil
  #popcorn => compounds
  @prices = {"10" => "2.50", "25" => "5", "50" => "9.50", "100" => "15", "200" => "25", "500" => "40"}
  @discounts = {"10" => "2", "25" => "3.50", "50" => "8", "100" => "10", "200" => "20", "500" => "30"}
  erb :payment
end

post '/addPopcorn' do

  popcorn_amount = (params[:popcorn_quantity]).to_i
  price = (params[:price]).to_f

  @form_was_submitted = true

  if session["logged_in"] == true 
    #update the popcorn and the com pounds balance in the table

    @user = session["user"]

    user = User.first(user_name: @user)

    #update the COM_POUNDS balance in the database if the user has enough money
    if user.compound < price
      @submission_error = "not enough money"
      @price_error = "not enough money"

    end

    minus_amount = user.compound - price
    
    user.compound = minus_amount
    user.save_changes

    #updates the popcorn balance in database
    new_amount = user.popcorn + popcorn_amount

    user.popcorn = new_amount
    user.save_changes

    if session[:creator_code]
      creator_user = User.first(creator_code: session[:creator_code])
      if creator_user && creator_user.user_name != @user  # ensure not self-gifting
        bonus_popcorn = (popcorn_amount * 0.1).floor
        creator_user.popcorn += bonus_popcorn
        creator_user.save_changes
      end
    end

    redirect "/" #this works
  else

    @login_error = "please log in. Redirecting..."

    @submission_error = "need to log in"

  end

  erb :payment
end

post '/getPremium' do

  price = (params[:price]).to_f
  @form_was_submitted = true

  if session["logged_in"] == true 
    #update the popcorn and the com pounds balance in the table

    @user = session["user"]

    user = User.first(user_name: @user)

    user.compound = 500.0 #testing purposes maybe go in create account?
    user.save_changes

    #update the COM_POUNDS balance in the database if the user has enough money
    if user.compound < price
      @submission_error = "not enough money"
      @price_error = "not enough money"

    end

    minus_amount = user.compound - price

    user.compound = minus_amount
    user.save_changes

    #gives the user premium 

    user.premium = 1
    user.save_changes

    redirect "/"
  end

  erb :payment
end

post '/checkCreatorCode' do
  submitted_code = params[:creatorCode].strip
  creator_user = User.first(creator_code: submitted_code)

  if creator_user
    session[:creator_code] = submitted_code 
    @code_check_result = true
  else
    @code_check_result = false
  end

  @prices = {"10" => "2.50", "25" => "5", "50" => "9.50", "100" => "15", "200" => "25", "500" => "40"}
  @discounts = {"10" => "2", "25" => "3.50", "50" => "8", "100" => "10", "200" => "20", "500" => "30"}
  erb :payment

end