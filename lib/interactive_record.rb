require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize
    end



    def self.column_names
        sql = "PRAGMA table_info('#{table_name}')"
        DB[:conn].execute(sql).collect do |row| 
            row["name"]
            #binding.pry
        end
    end



    def initialize(attr_hash={})
        attr_hash.each {|key, value| self.send("#{key}=", value)}
    end



    def table_name_for_insert
        self.class.table_name
    end

    
    
    def col_names_for_insert
        self.class.column_names.delete_if {|column| column == "id"}.join(", ")
    end

    
    
    def values_for_insert
       values = []
       self.class.column_names.each do |col_name|
        values << ("'#{send(col_name)}'") unless send(col_name).nil?
       end
       values.join(", ")
    end



    def save 
        sql = <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
        SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowId() FROM #{table_name_for_insert}")[0][0]
    end



    def self.find_by_name(name)
        sql = <<-SQL 
        SELECT * FROM #{table_name} WHERE name = ?
        SQL
    DB[:conn].execute(sql, name)
    end



    def self.find_by(attr_hash)
        sql = <<-SQL
        SELECT * FROM #{table_name} WHERE #{attr_hash.keys[0]} = #{attr_hash.values[0]}
        SQL
        DB[:conn].execute(sql)  
    end

end