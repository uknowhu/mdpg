require "rand_string_generator"

class User < ModelBase

  ATTRS = [:name, :email, :salt, :hashed_password, :access_token,
    :page_ids, :recent_edited_page_ids, :recent_viewed_page_ids, :clan_ids,
    :page_tags, :is_admin]

  attr_accessor *ATTRS

  def self.authenticate email, password
    user = self.find_by_index :email, email
    return nil if ! user
    if user.password_authenticates?(password)
      return user
    end
    nil
  end

  def create opts = {}
    @password = opts[:password]
    opts.delete :password
    super opts
  end

  def password= password
    @password = password
  end

  def save
    ensure_access_token()
    ensure_salt()
    possibly_create_hashed_password()
    super
  end

  def password_authenticates? password
    self.hashed_password == hash_this_password(password)
  end

  def add_page page
    add_associated_object page
    UserRecentPages.new(self).add_to_recent_edited_pages_list(page)
    save
  end

  def remove_page page
    remove_associated_object page
    UserRecentPages.new(self).remove_from_all_recent_pages_lists(page)
    save
  end

  def add_clan clan
    add_associated_object clan
    save
  end

  def remove_clan clan
    remove_associated_object clan
    save
  end

  private

    def unique_id_indexes
      [:email, :access_token]
    end

    def possibly_create_hashed_password
      if @password
        self.hashed_password = hash_this_password(@password)
      end
    end

    def hash_this_password(password)
      Digest::SHA1.hexdigest(password + self.salt)
    end

    def ensure_salt
      if ! self.salt
        self.salt = RandStringGenerator.rand_string_of_length 32
      end
    end

    def ensure_access_token
      if ! self.access_token
        self.access_token = RandStringGenerator.rand_string_of_length 32
      end
    end

end
