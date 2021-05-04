require "sinatra"
require "slim"
require "sqlite3"
require 'date'
require_relative "./model.rb"

enable :sessions

include Model

salt = "saltysaltysaltcandywithplentyofsalt"

# Display Landing Page and all recipes
# 
# @see Model#select_everything_from_recipes
get("/") do
  recipes = select_everything_from_recipes()
  slim(:"index", locals:{recipes:recipes})
end

# Displays the create a new recipe page
# 
get("/recipe/new") do
  slim(:"recipe/new")
end

# Creates a new recipe and redirects to "/"
# 
# @param [String] recipe_name, The name of the recipe
# @param [Integer] user_id, The ID of the user
# @param [String] ingredients, The ingredients of the recipe
# @param [String] instructions, The instructions of the recipe
# 
# @see Model#insert_intro_recipes
post("/recipe") do
  recipe_name = params[:recipe_name]
  user_id = session[:user_id]
  date_created = Time.now.to_s
  ingredients = params[:ingredients]
  instructions = params[:instructions]

  if recipe_name != "" && ingredients != "" && instructions != ""
    insert_into_recipes(recipe_name, user_id, date_created, ingredients, instructions)
    redirect("/")
  else
    "Please leave no fields empty."
  end
end

# Displays a single recipe and all of its likes
# 
# @param [Integer] recipe_id, The ID of the recipe
# 
# @see Model#select_everything_from_recipe_id
# @see Model#select_all_user_ids_from_like_id
get('/recipe/:id') do 
  recipe_id = params[:id].to_i
  all_data = select_everything_from_recipe_id(recipe_id)
  all_likes = select_all_user_ids_from_like_id(recipe_id)
  slim(:"recipe/show", locals:{all_data:all_data, all_likes:all_likes})
end

# Displays edit the current recipe page if the user is the author
# 
# @param [Integer] recipe_id, The ID of the recipe
# 
# @see Model#select_everything_from_recipe_id
get('/recipe/:id/edit') do
  recipe_id = params[:id].to_i
  all_data = select_everything_from_recipe_id(recipe_id)
  author_id = all_data["user_id"]
  if author_id == session[:user_id] || session[:admin] == "true"
    slim(:"recipe/edit", locals:{all_data:all_data})
  else
    "Can not edit a recipe you are not an author of."
  end

end

# Updates an existing recipe and redirects to "/"
# 
# @param [Integer] recipe_id, The ID of the recipe
# @param [String] recipe_name, The name of the recipe
# @param [String] ingredients, The ingredients of the recipe
# @param [String] instructions, The instructions of the recipe
# 
# @see Model#update_recipes
post("/recipe/:id/update") do
  recipe_id = params[:id].to_i
  recipe_name = params[:recipe_name]
  date_updated = Time.now.to_s
  ingredients = params[:ingredients]
  instructions = params[:instructions] 
  
  if recipe_name != "" && ingredients != "" && instructions != ""
    update_recipes(recipe_name, date_updated, ingredients, instructions, recipe_id)
    redirect("/")
  else
    "Please leave no fields empty."
  end
end

# Deletes an existing recipe if the user is the author and redirects to "/"
# 
# @param [Integer] recipe_id, The ID of the recipe
# 
# @see Model#select_everything_from_recipe_id
# @see Model#delete_recipe
post("/recipe/:id/delete") do
  recipe_id = params[:id].to_i
  author_id = select_everything_from_recipe_id(recipe_id)["user_id"]
  if author_id == session[:user_id] || session[:admin] == "true"
    delete_recipe(recipe_id)
    redirect('/')
  else
    "Can not delete a recipe you are not an author of."
  end
end

# Likes an existing recipe and redirects back to the same page (refreshes the current page)
# 
# @param [Integer] recipe_id, The ID of the recipe
# 
# @see Model#add_like
get("/recipe/:id/like") do
  recipe_id = params[:id].to_i
  add_like(recipe_id, session[:user_id])
  redirect(session[:redirect_link])
end

# Unlikes an existing recipe and redirects back to the same page (refreshes the current page)
# 
# @param [Integer] recipe_id, The ID of the recipe
# 
# @see Model#remove_like
get("/recipe/:id/unlike") do
  recipe_id = params[:id].to_i
  remove_like(recipe_id, session[:user_id])
  redirect(session[:redirect_link])
end

# Displays a register form
# 
get("/user/new") do
  slim(:"user/new")
end

# Creates a new user and redirects to "/"
# 
# @param [String] username, The username of the user
# @param [String] password_input, The inputed password of the user
# @param [String] password_confirmation, The second inputed password of the user
# 
# @see Model#username_exists
# @see Model#encrypt_password
# @see Model#create_new_user
post("/user") do
  username = params[:username]
  password_input = params[:password_input]
  password_confirmation = params[:password_confirmation]

  if username_exists(username) == []
    if password_input == password_confirmation
      password = password_input + salt
      password_encrypted = encrypt_password(password)
      create_new_user(username, password_encrypted)
      redirect("/")
    else
      "The passwords do not match!"
    end
  else
    "This username is taken."
  end
end

# Displays a login form and controls that the user has not failed to many logins
# 
get("/user/login") do
  if session[:next_attempt] != nil
    if session[:next_attempt] - Time.now <= 0
      session[:failed_attempts] = 0
    else
      time_left = session[:next_attempt] - Time.now
    end
  end
  slim(:"user/login", locals:{time_left:time_left})
end

# Attempts login and updates the session, the user can only attempt to login a limited amount of times
# 
# @param [String] username, The username
# @param [String] password_input, The inputed password
# 
# @see Model#username_exists
# @see Model#add_failed_attempt
# @see Model#select_user_information
# @see Model#decrypt_password
post("/user/login") do
  username = params[:username]
  password_input = params[:password_input]
  password = password_input + salt

  if username_exists(username) == []
    add_failed_attempt()
  else
    user_information = select_user_information(username)
    user_id = user_information["user_id"]
    password_encrypted = user_information["password"]
    if decrypt_password(password_encrypted) == password
      session[:failed_attempts] == 0
      session[:user_id] = user_id
      session[:username] = username
      if user_information["is_admin"] == "true"
        session[:admin] = "true"
      end
      redirect("/")
    else
      add_failed_attempt()
    end
  end
end

# Logs out and destroys the session
# 
get("/user/logout") do
    session.destroy
  redirect("/")
end