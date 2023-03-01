

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
   attr_reader :id
   attr_accessor :fname, :lname
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

   def authored_questions
      Question.find_by_author_id(id)
   end

   def authored_replies
      Reply.find_by_replier_id(id)
   end

   def followed_questions
      QuestionFollow.followed_questions_for_user_id(id)
   end


end

class Question
   attr_reader :id
   attr_accessor :title, :body, :author_id
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

   def self.most_followed(n)
      QuestionFollow.most_followed_questions(n)
   end


   def initialize(options)
      @id = options['id']
      @title = options['title']
      @body = options['body']
      @author_id = options['author_id']
   end

   def author
      User.find_by_id(author_id)
   end

   def replies
      Reply.find_by_question_id(id)
   end

   def followers
      QuestionFollow.followers_for_question_id(id)
   end

end

class Reply
   attr_reader :id
   attr_accessor :question_id, :parent_reply_id, :replier_id, :reply_body

   def self.find_by_id(id)
      reply = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT 
         * 
      FROM 
        replies 
      WHERE 
         id = ?
      SQL
      Reply.new(reply.first)
   end

   def self.find_replies_by_id(id)
      replies = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT 
         * 
      FROM 
        replies 
      WHERE 
         id = ?
      SQL
      replies.map{|ele| Reply.new(ele)}
   end



   def self.find_by_replier_id(replier_id)
      user_replies = QuestionDatabase.instance.execute(<<-SQL, replier_id)
      SELECT 
         * 
      FROM 
         replies
      WHERE 
         replier_id = ?
      SQL
      return nil if user_replies.empty?
      user_replies.map{|ele| Reply.new(ele)}
   end

   def self.find_by_question_id(question_id)
      question_replies = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
         * 
      FROM 
         replies
      WHERE 
         question_id = ?
      SQL
      return nil if question_replies.empty?
      question_replies.map{|ele| Reply.new(ele)}
   end

   def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @parent_reply_id = options['parent_reply_id']
      @replier_id = options['replier_id']
      @reply_body = options['reply_body']
   end
   
   def author
      User.find_by_id(replier_id)
   end

   def question
      Question.find_by_id(question_id)
   end

   def parent_reply
      Reply.find_by_id(parent_reply_id)
   end

   def child_replies
      replies = QuestionDatabase.instance.execute(<<-SQL, parent_reply_id )
      SELECT 
         * 
      FROM 
        replies 
      WHERE 
         parent_reply_id = ?
      SQL
      replies.map{|ele| Reply.new(ele)}
   end
end

class QuestionFollow
   attr_accessor :user_id, :question_id
   attr_reader :id
   def self.followers_for_question_id(question_id)
      followers = QuestionDatabase.instance.execute(<<-SQL, question_id)
         SElECT
          *
         FROM 
          users
         WHERE
            id IN (
            SELECT
               user_id
            FROM 
               question_follows
            WHERE
               question_id = ?
            )
      SQL
      return nil if followers.empty?
      followers.map{|ele| User.new(ele)}
   end

   def self.followed_questions_for_user_id(user_id)
      questions = QuestionDatabase.instance.execute(<<-SQL, user_id)
         SElECT
          *
         FROM 
          questions
         WHERE
            id IN (
            SELECT
               question_id
            FROM 
               question_follows
            WHERE
               user_id = ?
            )
      SQL
      return nil if questions.empty?
      questions.map{|ele| Question.new(ele)}
   end

   def self.find_by_id(id)
       questionfollows = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT 
         * 
      FROM 
        question_follows 
      WHERE 
         id = ?
      SQL
      QuestionFollow.new(questionfollows.first)
   end
   
   def self.most_followed_questions(n)
      most_followed_q = QuestionDatabase.instance.execute(<<-SQL, n)
        SELECT
          *
          FROM
          questions
         WHERE
         id IN (
         SELECT 
           question_id
         FROM
           question_follows
         GROUP BY 
         question_id
         ORDER BY
          Count(*) DESC
         LIMIT ?
         )
      SQL
      return nil if most_followed_q.empty?
      most_followed_q.map{|ele| Question.new(ele)}
   end

   def initialize(options)
      @id = options['id']
      @user_id = options['user_id']
      @question_id = options['question_id']
   end
end

class QuestionLike
   attr_accessor :user_liked_id, :question_liked_id
   attr_reader :id

   def self.likers_for_question_id(question_id)
      likers = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SElECT
         *
      FROM 
         users
      WHERE
         id IN (
         SELECT
            user_liked_id
         FROM 
            question_likes
         WHERE
            question_liked_id = ?
         )
      SQL
      return nil if likers.empty?
      likers.map{|ele| User.new(ele)}
   end

   def self.num_likes_for_question_id(question_id)
      num = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        Count(*)
      FROM
        question_likes
      WHERE
        question_liked_id = ?
      SQL
      num.first["Count(*)"]
   end

   def self.liked_questions_for_user_id(user_id)
      liked_questions = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
         *
      FROM
         questions
      WHERE
         id IN (
            SELECT
               question_liked_id
            FROM
               question_likes
            WHERE
               user_liked_id = ?

         )

      SQL

      return nil if liked_questions.empty?
      liked_questions.map{|ele| Question.new(ele)}
   end

   def initialize(options)
      @id = options['id']
      @user_liked_id = options['user_liked_id']
      @question_liked_id = options['question_liked_id']
   end



end

