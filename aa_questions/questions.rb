

require 'sqlite3'
require 'singleton'

class QuestionDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User

   attr_accessor :fname, :lname, :id
   def self.find_by_id(id)
      user = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT 
         * 
      FROM 
         users 
      WHERE 
         id = ?
      SQL
      User.new(user.first)
   end

   def initialize(options)
      @id = options['id']
      @fname = options['fname']
      @lname = options['lname']
   end
end

class Question
end