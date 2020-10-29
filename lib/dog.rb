class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save 
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
                VALUES(?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        return self
    end
    
    def self.create(name:, breed:)
        good_boy = Dog.new(name: name, breed: breed)
        good_boy.save
        return good_boy
    end

    def self.new_from_db(arry_row)
        good_boy = Dog.new(id: arry_row[0], name: arry_row[1], breed:arry_row[2])
        return good_boy
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            SQL

        Dog.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
            SQL
        
        good_boy = DB[:conn].execute(sql, name, breed)
        if !good_boy.empty?
            gb_data = good_boy[0]
            good_boy = Dog.new(id: gb_data[0], name: gb_data[1], breed: gb_data[2])
        else
            good_boy = Dog.create(name: name, breed: breed)
        end
        return good_boy
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            SQL

            Dog.new_from_db(DB[:conn].execute(sql, name)[0])
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        set name = ?, breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end