

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

   def self.find_by_name(fname, lname)
      user = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT 
         * 
      FROM 
         users 
      WHERE 
         fname = ?
      AND
         lname = ?
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
   attr_accessor :title, :body, :user_id
   def self.find_by_id(id)
      question = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT 
         * 
      FROM 
         questions 
      WHERE 
         id = ?
      SQL
      Question.new(question.first)
   end

   def self.find_by_author_id(author_id)
      user_questions = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT 
         * 
      FROM 
         questions
      WHERE 
         author_id = ?
      SQL
      return nil if user_questions.empty?
      user_questions.map{|ele| Question.new(ele)}
   end


   def initialize(options)
      @id = options['id']
      @title = options['title']
      @body = options['body']
      @author_id = options['author_id']
   end

end