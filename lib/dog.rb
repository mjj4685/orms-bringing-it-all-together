class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed

    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES(?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attribute_hash)
        dog = Dog.new(attribute_hash)
        dog.save 
        dog
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.find_by_id(id)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            result = dog.first
            dog = Dog.new(id: result[0], name: result[1], breed: result[2])
        else
            dog = self.create(name: name, breed: breed)
        end

    end

    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end


    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end
