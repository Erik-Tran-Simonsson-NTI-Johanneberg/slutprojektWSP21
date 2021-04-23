require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require 'date'
require_relative "./model.rb"

enable :sessions

include Model

salt = "saltysaltysaltcandywithplentyofsalt"

# Displays frontpage
# 
# @see Model#select_everything_from_recipes
get("/") do
  recipes = select_everything_from_recipes()
  slim(:"index", locals:{recipes:recipes})
end

get("/recipe/new") do
  slim(:"recipe/new")
end

post("/recipe") do
  recipe_name = params[:recipe_name]
  user_id = session[:user_id]
  date_created = Time.now.getutc.to_s
  ingredients = params[:ingredients]
  instructions = params[:instructions]

  if recipe_name != "" && ingredients != "" && instructions != ""
    insert_into_recipes(recipe_name, user_id, date_created, ingredients, instructions)
    redirect("/")
  else
    "Please leave no fields empty."
  end
end

get('/recipe/:id') do 
  recipe_id = params[:id].to_i
  all_data = select_everything_from_recipe_id(recipe_id)
  all_likes = select_all_user_ids_from_like_id(recipe_id)
  slim(:"recipe/show", locals:{all_data:all_data, all_likes:all_likes})
end

get('/recipe/:id/edit') do
  recipe_id = params[:id].to_i
  all_data = select_everything_from_recipe_id(recipe_id)
  slim(:"recipe/edit", locals:{all_data:all_data})
end

post("/recipe/:id/update") do
  recipe_id = params[:id].to_i
  recipe_name = params[:recipe_name]
  date_updated = Time.now.getutc.to_s
  ingredients = params[:ingredients]
  instructions = params[:instructions] 
  
  if recipe_name != "" && ingredients != "" && instructions != ""
    update_recipes(recipe_name, date_updated, ingredients, instructions, recipe_id)
    redirect("/")
  else
    "Please leave no fields empty."
  end
end

get("/recipe/:id/delete") do
  recipe_id = params[:id].to_i
  delete_recipe(recipe_id)
  redirect('/')
end

get("/recipe/:id/like") do
  recipe_id = params[:id].to_i
  add_like(recipe_id, session[:user_id])
  redirect(session[:redirect_link])
end

get("/recipe/:id/unlike") do
  recipe_id = params[:id].to_i
  remove_like(recipe_id, session[:user_id])
  redirect(session[:redirect_link])
end

get("/user/new") do
  slim(:"user/new")
end

post("/user") do
  username = params[:username]
  password_input = params[:password_input]
  password_confirmation = params[:password_confirmation]

  if username_exists(username) == []
    if password_input == password_confirmation
      password = password_input + salt
      password_encrypted = BCrypt::Password.create(password)
      create_new_user(username, password_encrypted)
      redirect("/")
    else
      "The passwords do not match!"
    end
  else
    "This username is taken."
  end
end

get("/user/login") do
  slim(:"user/login")
end

post("/user/login") do
  username = params[:username]
  password_input = params[:password_input]
  password = password_input + salt

  if username_exists(username) == []
    "Incorrect username or password, please try again."
  else
    user_information = select_user_information(username)
    user_id = user_information["user_id"]
    password_encrypted = user_information["password"]
    if BCrypt::Password.new(password_encrypted) == password
      session[:user_id] = user_id
      session[:username] = username
      if user_information["is_admin"] == "true"
        session[:admin] = "true"
      end
      redirect("/")
    else
      "Incorrect username or password, please try again."
    end
  end
end

get("/user/logout") do
    session.destroy
  redirect("/")
end