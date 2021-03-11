def get_db()
    return SQLite3::Database.new("db/database.db")
end

def get_db_as_hash()
    db = get_db()
    db.results_as_hash = true
    return db
end

def select_everything_from_recipes()
    return get_db_as_hash().execute("SELECT * FROM recipes")
end

def select_everything_from_recipe_id(recipe_id)
    return get_db_as_hash().execute("SELECT * FROM recipes WHERE recipe_id = ?", recipe_id).first
end

def insert_into_recipes(recipe_name, user_id, date_created, ingredients, instructions)
    return get_db().execute("INSERT INTO recipes (recipe_name, user_id, date_created, ingredients, instructions) VALUES (?, ?, ?, ?, ?)", recipe_name, user_id, date_created, ingredients, instructions)
end

def update_recipes(recipe_name, date_updated, ingredients, instructions, recipe_id)
    return get_db().execute("UPDATE recipes SET recipe_name = ?, date_updated = ?, ingredients = ?, instructions = ? WHERE recipe_id = ?", recipe_name, date_updated, ingredients, instructions, recipe_id)
end

def delete_recipe(recipe_id)
    return get_db().execute("DELETE FROM recipes WHERE recipe_id = ?", recipe_id)
end

def create_new_user(username, password)
    return get_db().execute("INSERT INTO users (username, password) VALUES (?, ?)", username, password)
end

def select_user_information(username)
    return get_db_as_hash().execute("SELECT * FROM users WHERE username = ?", username).first
end