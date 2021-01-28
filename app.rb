require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

#1. Skapa ER + databas som kan hålla användare och todos. Fota ER-diagram, 
#   lägg i misc-mapp
#2. Skapa ett formulär för att registrerara användare.
#3. Skapa ett formulär för att logga in. Om användaren lyckas logga  
#   in: Spara information i session som håller koll på att användaren är inloggad
#4. Låt inloggad användare skapa todos i ett formulär (på en ny sida ELLER på sidan som visar todos.).
#5. Låt inloggad användare updatera och ta bort sina formulär.
#6. Lägg till felhantering (meddelande om man skriver in fel user/lösen)

enable :sessions

get("/") do
  slim(:register)
end

post("/users/new") do
  db = SQLite3::Database.new("db/todo2021.db")

  username = params[:username]
  password_input = params[:password_input]
  password_confirmation = params[:password_confirmation]

  if password_input == password_confirmation
    password = password_input + "salt"
    password_encrypt = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, password) VALUES (?, ?)", username, password_encrypt)
    redirect("/")

  else
    "The passwords do not match!"
  end
end

get("/showlogin") do
  slim(:login)
end

post("/login") do
  db = SQLite3::Database.new("db/todo2021.db")
  db.results_as_hash = true

  username = params[:username]
  password_input = params[:password_input] + "salt"

  result = db.execute("SELECT * FROM users WHERE username = ?", username).first
  user_id = result["user_id"]
  password = result["password"]

  if BCrypt::Password.new(password) == password_input
    session[:user_id] = user_id
    session[:username] = username
    redirect("/todos")
  
  else
    "Incorrect username or password, please try again."
  end
end

get("/todos") do
  db = SQLite3::Database.new("db/todo2021.db")
  db.results_as_hash = true

  user_id = session[:user_id].to_i
  username = session[:username]

  result = db.execute("SELECT * FROM todos WHERE user_id = ?", user_id)
  slim(:"todos/index", locals:{todos:result})
end

get('/todos/new') do
  slim(:"todos/new")
end

post("/todos/new") do
  db = SQLite3::Database.new("db/todo2021.db")

  content = params[:content]
  user_id = session[:user_id].to_i
  
  db.execute("INSERT INTO todos (content, user_id) VALUES (?, ?)", content, user_id)
  redirect("/todos")
end

post("/todos/:todos_id/update") do
  db = SQLite3::Database.new("db/todo2021.db")

  todos_id = params[:todos_id].to_i
  content = params[:content]

  db.execute("UPDATE todos SET content=? WHERE todos_id=?", content, todos_id)
  redirect("/todos")
end

get("/todos/:todos_id/edit") do
  db = SQLite3::Database.new("db/todo2021.db")
  db.results_as_hash = true

  todos_id = params[:todos_id].to_i

  result = db.execute("SELECT * FROM todos WHERE todos_id = ?", todos_id).first
  slim(:"/todos/edit", locals:{result:result})
end

post("/todos/:todos_id/delete") do
  db = SQLite3::Database.new("db/todo2021.db")
  todos_id = params[:todos_id].to_i

  db.execute("DELETE FROM todos WHERE todos_id = ?", todos_id)
  redirect("/todos")
end