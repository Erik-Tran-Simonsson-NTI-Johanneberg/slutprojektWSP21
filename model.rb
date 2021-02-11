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

def insert_into_recipes(recipe_name, user_id, date_created, ingredients, instructions)
    return get_db().execute("INSERT INTO recipes (recipe_name, user_id, date_created, ingredients, instructions) VALUES (?, ?, ?, ?, ?)", recipe_name, user_id, date_created, ingredients, instructions)
end

def select_all_data_from_recipe(recipe_id)
    recipe_name = get_db_as_hash().execute("SELECT recipe_name FROM recipes WHERE recipe_id = ?", recipe_id).first
    user_id = get_db_as_hash().execute("SELECT user_id FROM recipes WHERE recipe_id = ?", recipe_id).first
    date_created = get_db_as_hash().execute("SELECT date_created FROM recipes WHERE recipe_id = ?", recipe_id).first
    ingredients = get_db_as_hash().execute("SELECT ingredients FROM recipes WHERE recipe_id = ?", recipe_id).first
    instructions = get_db_as_hash().execute("SELECT instructions FROM recipes WHERE recipe_id = ?", recipe_id).first
    return [recipe_name, user_id, date_created, ingredients, instructions]
end