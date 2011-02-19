require 'sqlite3'
require 'openssl'
require 'yaml'

class Database
  def initialize
    @db = SQLite3::Database.new("emails.db")
    create_table
  end
  def modulus
    rows = @db.execute("SELECT modulus FROM keys")
    p rows
    if rows.nil? || rows.empty?
      p "creating modulus"
      key = generate_key
      @db.execute("INSERT INTO keys VALUES('#{key.n}','#{key.e}')")
      return key.n
    end
    return rows.first.first
  end
  def mail(modulus)
    p modulus
    mail_array = @db.execute("SELECT * FROM mail WHERE modulus = '#{modulus}'")
    mail_array.map do |mail_item|
      { "modulus" => mail_item[0], "body" => mail_item[1], "timestamp" => mail_item[2] }
    end
  end
  def create_table
    @db.execute("CREATE TABLE IF NOT EXISTS mail (modulus,message,timestamp)")
    @db.execute("CREATE TABLE IF NOT EXISTS keys (modulus,encryption)")
    @db.execute("CREATE TABLE IF NOT EXISTS hosts (modulus)")
  end
  def save_message(modulus,msg,time)
    @db.execute("INSERT INTO mail VALUES('#{modulus}','#{msg}','#{time}')")
  end
  def generate_key
    OpenSSL::PKey::RSA.new(128)
  end
  def add_host(modulus)
    @db.execute("INSERT INTO hosts VALUES('#{modulus}')")
  end
  def hosts
    @db.execute("SELECT modulus FROM hosts")
  end
  def servers
    server = @db.execute("SELECT server from servers")
    if server.empty?
      config = YAML::load_file("./server.config")
      @db.execute("INSERT into servers VALUES('#{config["server"]}')")
      return config["server"]
    end
    return false
  end
end
