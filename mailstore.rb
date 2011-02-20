require 'pstore'
require 'ostruct'

class Mail < OpenStruct
end
class Database
  def initialize
    @store = PStore.new("mail_storage")
  end
  def mail(user)
    @store.transaction do
      return @store['mail:#{user}']
    end
  end
  def store(options)
    @store.transaction do
      @store['mail:#{options[:user]}'] ||= []
      mail = Mail.new
      mail.from = options[:from]
      mail.message = options[:message]
      mail.time = options[:time]
      @store['mail:#{options[:user]}'] << mail
    end
  end
  def add_host(host)
    @store.transaction do
      @store['hosts'] ||= []
      @store['hosts'] << host
    end
  end
  def hosts
    @store.transaction do
      return @store['hosts']
    end
  end
  def modulus
    @store.transaction do
      mod = @store['modulus']
      if mod.nil?
        p "creating modulus"
        key = generate_key
        @store['n'] = key.n
        @store['e'] = key.e
        return key.n
      end
    end
    return mod
  end
end