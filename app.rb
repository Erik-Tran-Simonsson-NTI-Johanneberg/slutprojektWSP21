require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require 'date'
require_relative "./model.rb"

enable :sessions

db = get_db()

get("/") do
  recipes = select_everything_from_recipes()
  slim(:"frontpage", locals:{recipes:recipes})
end

get("/recipe/new") do
  slim(:"recipe/new")
end

post("/recipe/new") do
  recipe_name = params[:recipe_name]
  user_id = 1
  date_created = Time.now.getutc.to_s
  ingredients = params[:ingredients]
  instructions = params[:instructions]
  
  insert_into_recipes(recipe_name, user_id, date_created, ingredients, instructions)
  redirect("/")
end

get('/recipe/:id') do 
  recipe_id = params[:id].to_i
  all_data = select_everything_from_recipe_id(recipe_id)
  slim(:"recipe/show", locals:{all_data:all_data})
end

get('/recipe/:id/edit') do
  recipe_id = params[:id].to_i
  all_data = select_everything_from_recipe_id(recipe_id)
  slim(:"recipe/edit", locals:{all_data:all_data})
end

post("/recipe/:id/edit") do
  recipe_id = params[:id].to_i
  recipe_name = params[:recipe_name]
  date_updated = Time.now.getutc.to_s
  ingredients = params[:ingredients]
  instructions = params[:instructions]  
  update_recipes(recipe_name, date_updated, ingredients, instructions, recipe_id)
  redirect("/")
end

get("/recipe/:id/delete") do
  recipe_id = params[:id].to_i
  delete_recipe(recipe_id)
  redirect('/')
end