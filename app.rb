require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
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
  date_created = 1
  ingredients = params[:ingredients]
  instructions = params[:instructions]
  
  insert_into_recipes(recipe_name, user_id, date_created, ingredients, instructions)
  redirect("/")
end

get('/recipe/:id') do  
  recipe_id = params[:id].to_i
  recipe_name = select_all_data_from_recipe(recipe_id)[0]
  user_id = select_all_data_from_recipe(recipe_id)[1]
  date_created = select_all_data_from_recipe(recipe_id)[2]
  ingredients = select_all_data_from_recipe(recipe_id)[3]
  instructions = select_all_data_from_recipe(recipe_id)[4]
  slim(:"recipe/show", locals:{recipe_name:recipe_name, user_id:user_id, date_created:date_created, ingredients:ingredients, instructions:instructions})
end