require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

enable :sessions

get("/") do
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true

  recipes = db.execute("SELECT * FROM recipes")
  slim(:"frontpage", locals:{recipes:recipes})
end

get("/recipe/new") do
  slim(:"recipe/new")
end

post("/recipe/new") do
  db = SQLite3::Database.new("db/database.db")

  recipe_name = params[:recipe_name]
  user_id = 1
  date_created = 1
  ingredients = params[:ingredients]
  instructions = params[:instructions]
  
  db.execute("INSERT INTO recipes (recipe_name, user_id, date_created, ingredients, instructions) VALUES (?, ?, ?, ?, ?)", recipe_name, user_id, date_created, ingredients, instructions)
  redirect("/")
end

get('/recipe/:id') do
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  
  recipe_id = params[:id].to_i
  recipe_name = db.execute("SELECT recipe_name FROM recipes WHERE recipe_id = ?", recipe_id).first
  user_id = db.execute("SELECT user_id FROM recipes WHERE recipe_id = ?", recipe_id).first
  date_created = db.execute("SELECT date_created FROM recipes WHERE recipe_id = ?", recipe_id).first
  ingredients = db.execute("SELECT ingredients FROM recipes WHERE recipe_id = ?", recipe_id).first
  instructions = db.execute("SELECT instructions FROM recipes WHERE recipe_id = ?", recipe_id).first
  slim(:"recipe/show", locals:{recipe_name:recipe_name, user_id:user_id, date_created:date_created, ingredients:ingredients, instructions:instructions})
end