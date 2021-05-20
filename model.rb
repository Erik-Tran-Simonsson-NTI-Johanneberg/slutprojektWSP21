require "bcrypt"

module Model

    # Grants access to the database
    # 
    # @return [?] containing the entire database
    def get_db()
        return SQLite3::Database.new("db/database.db")
    end

    # Outputs the database in a hash-format
    # 
    # @return [Hash] containing the entire database as a hash
    def get_db_as_hash()
        db = get_db()
        db.results_as_hash = true
        return db
    end

    # Outputs all data from the recipes table
    # 
    # @return [Hash]
    def select_everything_from_recipes()
        return get_db_as_hash().execute("SELECT * FROM recipes")
    end

    # Outputs all data of a recipe
    # 
    # @param [Integer] id, The ID of the recipe
    # 
    # @return [Hash]
    #   * :recipe_id [Integer] The ID of the recipe
    #   * :recipe_name [String] The name of the recipe
    #   * :user_id [Integer] The ID of the user
    #   * :date_created [String] The date of the creation of the recipe
    #   * :date_updated [String] The date of the most recent update
    #   * :ingredients [String] The ingredients of the recipe
    #   * :instructions [String] The instructions of the recipe
    def select_everything_from_recipe_id(recipe_id)
        return get_db_as_hash().execute("SELECT * FROM recipes WHERE recipe_id = ?", recipe_id).first
    end

    # Creates a row in the recipes table
    # 
    # @param [String] recipe_name, The name of the recipe
    # @param [Integer] user_id, The ID of the user
    # @param [String] date_created, The date of the recipe creation
    # @param [String] ingredients, The ingredients of the recipe
    # @param [Integer] instructions, The instructions of the recipe
    def insert_into_recipes(recipe_name, user_id, date_created, ingredients, instructions)
        return get_db().execute("INSERT INTO recipes (recipe_name, user_id, date_created, ingredients, instructions) VALUES (?, ?, ?, ?, ?)", recipe_name, user_id, date_created, ingredients, instructions)
    end

    # Updates a row in the recipes table
    # 
    # @param [String] recipe_name, The name of the recipe
    # @param [Integer] user_id, The ID of the user
    # @param [String] date_updated, The date of the latest recipe update
    # @param [String] ingredients, The ingredients of the recipe
    # @param [Integer] instructions, The instructions of the recipe
    def update_recipes(recipe_name, date_updated, ingredients, instructions, recipe_id)
        return get_db().execute("UPDATE recipes SET recipe_name = ?, date_updated = ?, ingredients = ?, instructions = ? WHERE recipe_id = ?", recipe_name, date_updated, ingredients, instructions, recipe_id)
    end

    # Deletes a row from the recipes table and all the associated likes
    # 
    # @param [Integer] recipe_id, The ID of the recipe
    def delete_recipe(recipe_id)
        get_db().execute("DELETE FROM likes WHERE recipe_id = ?", recipe_id)
        return get_db().execute("DELETE FROM recipes WHERE recipe_id = ?", recipe_id)
    end

    # Outputs all user_ids that like a recipe
    # 
    # @param [Integer] recipe_id, The ID of the recipe
    # 
    # @return [Array] all of user_ids that liked the recipe
    def select_all_user_ids_from_like_id(recipe_id)
        return get_db().execute("SELECT user_id FROM likes WHERE recipe_id = ?", recipe_id)
    end

    # Adds an user_id into a row in the likes table
    # 
    # @param [Integer] recipe_id, The ID of the recipe
    # @param [Integer] user_id, The ID of the user
    def add_like(recipe_id, user_id)
        return get_db().execute("INSERT INTO likes (recipe_id, user_id) VALUES (?, ?)", recipe_id, user_id)
    end

    # Deletes an user_id from a row in the likes table
    # 
    # @param [Integer] recipe_id, The ID of the recipe
    # @param [Integer] user_id, The ID of the user
    def remove_like(recipe_id, user_id)
        return get_db().execute("DELETE FROM likes WHERE recipe_id = ? AND user_id = ?", recipe_id, user_id)
    end

    # Creates a row in the users table
    # 
    # @param [String] username, The username of the user
    # @param [String] password, The password of the user
    def create_new_user(username, password)
        return get_db().execute("INSERT INTO users (username, password) VALUES (?, ?)", username, password)
    end

    # Controls if the username exists within a row in the users table
    # 
    # @param [String] username, The username of the user
    def username_exists(username)
        return get_db_as_hash().execute("SELECT * FROM users WHERE username = ?", username)
    end

    # Encrypts the password
    # 
    # @param [String] password, The password of the user
    # 
    # @return [String] the encrypted password
    def encrypt_password(password)
        return BCrypt::Password.create(password)
    end

    # Decrypts the encrypted password
    # 
    # @param [String] encrypted password, The encrypted password of the user
    # 
    # @return [String] the decrypted password
    def decrypt_password(password_encrypted)
        return BCrypt::Password.new(password_encrypted)
    end

    # Outputs all data of a user
    # 
    # @param [Integer] username, The username of the user
    # 
    # @return [Hash]
    #   * :user_id [Integer] The ID of the user
    #   * :username [String] The username of the user
    #   * :password [String] The password of the user
    def select_user_information(username)
        return get_db_as_hash().execute("SELECT * FROM users WHERE username = ?", username).first
    end
    
end