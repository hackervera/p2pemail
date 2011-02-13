require 'sqlite3'

class Database
  def initialize
    @db = SQLite3::Database.new("emails.db")
    create_table
  end
  def get_mail_for_user(modulus)
    p modulus
    @db.execute("SELECT * FROM mail WHERE modulus = '#{modulus}'")
  end
  def create_table
    @db.execute("CREATE TABLE IF NOT EXISTS mail (modulus,message,timestamp)")
  end
end
