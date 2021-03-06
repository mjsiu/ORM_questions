require 'singleton'
require 'sqlite3'

class QuestionsDataBase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

  self.results_as_hash = true
  self.type_translation = true
  end
end

class User
  attr_accessor :id, :fname, :lname

  def self.all
    results = QuestionsDataBase.instance.execute('SELECT * FROM users')
    results.map { |result| User.new(result) }
  end

  def initialize(options = {} )
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    results = QuestionsDataBase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = (?)
    SQL

    results.map { |result| User.new(result) }
  end

  def self.find_by_name(fname, lname)
    results = QuestionsDataBase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = (?) AND lname = (?)
    SQL

    results.map { |result| User.new(result) }
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questons
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma

    authored_questions.count.fdiv(liked_questions.count)

    # results = QuestionsDataBase.instance.execute(<<-SQL)
    #   SELECT
    #     (questions.id) CAST(COUNT(question_likes.user_id) as FLOAT)
    #   FROM
    #     questions
    #   LEFT OUTER JOIN
    #     question_likes ON questions.id = question_likes.question_id
    #   WHERE
    #     question_likes.user_id = #{self.id} OR questions.id = #{self.id}
    #
    #   SQL

    #results.first.values.first
  end

end

class Question
  attr_accessor :id, :title, :body, :user_id

  def self.all
    results = QuestionsDataBase.instance.execute('SELECT * FROM questions')
    results.map { |result| Question.new(result) }
  end

  def initialize(options = {} )
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_author_id(user_id)
    results = QuestionsDataBase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = (?)
    SQL

    results.map { |result| Question.new(result) }
  end

  def author
    @user_id
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def self.find_by_id(id)
    results = QuestionsDataBase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = (?)
    SQL

    results.map { |result| Question.new(result) }
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def number_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
end

class Reply
  attr_accessor :id, :question_id, :parent_id, :user_id, :body

  def self.all
    results = QuestionsDataBase.instance.execute('SELECT * FROM replies')
    results.map { |result| Reply.new(result) }
  end

  def initialize(options = {} )
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDataBase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = (?)
    SQL

    results.map { |result| Reply.new(result) }
  end

  def find_by_question_id(question_id)
    results = QuestionsDataBase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = (?)
    SQL

    results.map { |result| Reply.new(result) }
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Questions.find_by_id(self.id)
  end

  def parent_reply
    Reply.find_by_user_id(self.parent_id)
  end

  def child_replies
    result =  QuestionsDataBase.instance.execute(<<-SQL, self.id)
    SELECT
      *
    FROM
      replies
    WHERE
      parent_id = (?)
    SQL

    results.map { |result| Reply.new(result) }
  end

end

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

    def self.all
      results = QuestionsDataBase.instance.execute('SELECT * FROM question_follows')
      results.map { |result| Question_follow.new(result) }
    end

    def initialize(options = {} )
      @id = options['id']
      @user_id = options['user_id']
      @question_id = options['question_id']
    end

    def self.followers_for_question_id(question_id)
      results = QuestionsDataBase.instance.execute(<<-SQL, question_id)
      SELECT
        u.*
      FROM
        users AS u
      JOIN
        question_follows AS q ON u.id = q.user_id
      WHERE
        q.question_id = (?)
      SQL

      results.map { |result| User.new(result) }
    end

    def self.followers_for_user_id(user_id)
      results = QuestionsDataBase.instance.execute(<<-SQL, user_id)
      SELECT
        q.*
      FROM
        questions AS q
      JOIN
        question_follows AS qf ON q.id = qf.question_id
      WHERE
        qf.user_id = (?)
      SQL

      results.map { |result| Question.new(result) }
    end

    def self.most_followed_questions(n)
      results = QuestionsDataBase.instance.execute(<<-SQL, n)
      SELECT
        q.*
      FROM
        questions AS q
      JOIN
        question_follows AS qf ON q.id = qf.question_id
      JOIN
        users AS u on qf.user_id = u.id
      GROUP BY
        q.id
      ORDER BY
        COUNT(u.id) DESC
      LIMIT
        (?)
      SQL

      results.map { |result| Question.new(result) }
    end

end

class QuestionLike

  attr_accessor :id, :user_id, :question_id, :number_likes

    def self.all
      results = QuestionsDataBase.instance.execute('SELECT * FROM question_likes')
      results.map { |result| QuestionLike.new(result) }
    end

    def initialize(options = {} )
      @id = options['id']
      @number_likes = options['number_likes']
      @question_id = options['question_id']
      @user_id = options['user_id']
    end

    def self.likers_for_question_id(question_id)
      results = QuestionsDataBase.instance.execute(<<-SQL, question_id)
      SELECT
        u.*
      FROM
        users u
      JOIN
        question_likes ql ON ql.user_id = u.id
      WHERE
        ql.question_id = (?)
      SQL

      results.map { |result| User.new(result) }
    end

    def self.num_likes_for_question_id(question_id)
      results = QuestionsDataBase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(u.id) likes
      FROM
        users u
      JOIN
        question_likes ql ON ql.user_id = u.id
      WHERE
        ql.question_id = (?)
      SQL

      results.first.values.first
    end

    def self.liked_questions_for_user_id(user_id)
      results = QuestionsDataBase.instance.execute(<<-SQL, user_id)
        SELECT
          q.*
        FROM
          questions q
        JOIN
          question_likes ON question_likes.question_id = q.id
        WHERE
          question_likes.user_id = (?)
        SQL

        results.map { |result| Question.new(result) }
    end

    def self.most_liked_questions(n)
      results = QuestionsDataBase.instance.execute(<<-SQL, n)
      SELECT
        q.*
      FROM
        questions AS q
      JOIN
        question_likes AS ql ON q.id = ql.question_id
      JOIN
        users AS u on ql.user_id = u.id
      GROUP BY
        q.id
      ORDER BY
        COUNT(u.id) DESC
      LIMIT
        (?)
      SQL

      results.map { |result| Question.new(result) }
    end

end
