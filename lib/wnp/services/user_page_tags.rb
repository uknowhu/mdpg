require "similar_token_finder"

module Wnp::Services

  class UserPageTags < Struct.new(:user, :page)

    def add_tag tag_name, page_id
      if error = Wnp::Token.new(tag_name).validate
        return false
      end

      h = get_tags_hash()
      if ! h.has_key?(tag_name)
        h[tag_name] = {}
      end
      h[tag_name][page_id.to_s] = true
      user.page_tags = h
      user.save
    end

    def remove_tag tag_name, page_id
      if error = Wnp::Token.new(tag_name).validate
        return false
      end

      h = get_tags_hash()
      if ! h.has_key?(tag_name)
        return
      else
        if h[tag_name].has_key?(page_id.to_s)
          h[tag_name].delete(page_id.to_s)
          if h[tag_name].keys.size == 0
            h.delete(tag_name)
          end
        end
      end

      user.page_tags = h
      user.save

    end

    def search query
      SimilarTokenFinder.new.get_similar_tokens(query, get_tags())
    end

    def get_tags
      get_tags_hash().keys.sort
    end

    def has_tag_with_name? tag
      get_tags_hash().has_key?(tag)
    end

    def tag_count tag
      h = get_tags_hash()
      return 0 if ! h.has_key?(tag)
      return h[tag].keys.size
    end

    private

      def get_tags_hash
        h = user.page_tags || {}
        h.default = {}
        h
      end

  end

end
