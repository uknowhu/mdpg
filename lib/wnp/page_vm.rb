require 'redcarpet'

module Wnp

  class PageVm < Struct.new(:env, :page)

    def add_tag tag
      if page_tags().add_tag(tag)
        user_page_tags().add_tag(tag, page.id)
      end
    end

    def remove_tag tag
      if page_tags().remove_tag(tag)
        user_page_tags().remove_tag(tag, page.id)
      end
    end

    def rendered_html
      markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
      markdown.render page.text
    end

    private

      def page_tags
        Wnp::PageTags.new(env.data, page.id)
      end

      def user_page_tags
        Wnp::Services::UserPageTags.new(env.data, page.id)
      end

  end

end