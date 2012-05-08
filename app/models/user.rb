require 'digest/sha1'

class User < ActiveRecord::Base
  validates_length_of :username, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :username, :password, :salt
  validates_uniqueness_of :username, :password
  validates_confirmation_of :password

  def self.hash(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def self.randstr(length)
    charset = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    str = ''

    1.upto(length) do |i|
      str << charset[rand(charset.size-1)]
    end

    str
  end

  def self.authenticate(user, pass)
    user = find(:first, :condition => ["username = ?", user])

    return nil if !user

    return user if User.encrypt(pass, user.salt) == user.password_hash

    return nil
  end
end
