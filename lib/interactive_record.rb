require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name 
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    col_name = []
    DB[:conn].execute("PRAGMA table_info(#{self.table_name})").each do |col|
      col_name << col["name"]
    end
    col_name
  end
  
  def initialize(hash={})
    hash.each {|key, value| self.send("#{key}=", value)}
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  
  def values_for_insert 
    values = []
    self.class.column_names.each {|col| values << "'#{send(col)}'" unless send(col).nil?}
    values.join(", ")
  end
  
  def save 
    DB[:conn].execute("INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})")
    self.id = DB[:conn].execute("SELECT last_insert_rowId() FROM #{self.table_name_for_insert}")[0][0]
    self
  end
  
  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
  end
  
  def self.find_by(attr_hash)
  # condition = attr_hash.tap {|c| "#{c.to_s}= ?"}.join("AND") 
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{attr_hash.keys.join} = ?", attr_hash.values)
    
  end
end