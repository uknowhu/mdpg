require 'redcarpet'

class PageView < Struct.new(:user, :page)

  def name
    page.name
  end

  def add_tag tag
    if page_tags().add_tag(tag)
      user_page_tags().add_tag tag
      return true
    end
    false
  end

  def remove_tag tag
    if page_tags().remove_tag(tag)
      user_page_tags().remove_tag tag
      return true
    end
    false
  end

  def tag_suggestions_for partial_or_full_tag_name
    if partial_or_full_tag_name == "*"
      all_tags = user_page_tags.get_tags()
    else
      all_tags = user_page_tags.search(partial_or_full_tag_name)
    end
    all_tags - ObjectTags.new(page).sorted_tag_names()
  end

  def rendered_markdown
    markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :autolink => true, :space_after_headers => true)
    markdown.render page.text
  end

  private

    def page_tags
      ObjectTags.new(page)
    end

    def user_page_tags
      UserPageTags.new(user, page)
    end

end