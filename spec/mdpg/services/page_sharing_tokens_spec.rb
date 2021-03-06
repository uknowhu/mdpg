require_relative "../../spec_helper"

describe PageSharingTokens do

  before do
    $data_store = get_memory_datastore()
  end

  def create_page_with_name name
    Page.create name:name, text:"foo"
  end

  describe "finding by various sharing tokens" do

    it "should find by activated readonly_sharing_token" do
      create_page_with_name "not-the-page"
      page = create_page_with_name "the-page"
      assert_equal page.readonly_sharing_token.size, 32
      PageSharingTokens.new(page).activate_sharing_token :readonly

      found_page, token_type = PageSharingTokens.find_page_by_token(
                                      page.readonly_sharing_token)
      assert_equal page.id, found_page.id
    end

    it "should find by activated readwrite_sharing_token" do
      page = create_page_with_name "the-page"
      assert_equal page.readwrite_sharing_token.size, 32
      PageSharingTokens.new(page).activate_sharing_token :readwrite

      found_page, token_type = PageSharingTokens.find_page_by_token(
                                      page.readwrite_sharing_token)
      assert_equal page.id, found_page.id
    end

    it "should not find if the token is not activated" do
      page = create_page_with_name "the-page"
      assert_equal page.readwrite_sharing_token.size, 32
      found_page, token_type = PageSharingTokens.find_page_by_token(
                                      page.readwrite_sharing_token)
      assert found_page == nil
    end

  end

  describe "renaming sharing token" do

    def create_page_and_rename_token_to type, name
      @page = create_page_with_name "the-page"
      tokens = PageSharingTokens.new(@page)
      tokens.activate_sharing_token type
      tokens.rename_sharing_token(type, name)
    end

    it "should work if the token is a valid token and not already taken" do
      result = create_page_and_rename_token_to :readonly, "my-wish-list"
      assert_equal nil, result
      found_page, token_type =
        PageSharingTokens.find_page_by_token "my-wish-list"
      assert_equal @page.id, found_page.id
    end

    it "should not work if the token is not valid" do
      result = create_page_and_rename_token_to :readonly, "h"
      assert_equal :too_short, result
      found_page, token_type = PageSharingTokens.find_page_by_token "h"
      assert_equal nil, found_page
    end

    it "should throw exception if token is already taken by other page" do
      other_page = create_page_with_name "other-page"
      PageSharingTokens.new(other_page).activate_sharing_token :readonly

      page = create_page_with_name "the-page"
      assert_raises(SharingTokenAlreadyExistsException) {
        tokens = PageSharingTokens.new(page)
        tokens.activate_sharing_token :readonly
        tokens.rename_sharing_token(:readonly,
                                    other_page.readonly_sharing_token)
      }
    end

    it "should not throw exception if token is already taken by same page" do
      page = create_page_with_name "the-page"
      tokens = PageSharingTokens.new(page)
      tokens.activate_sharing_token :readonly
      tokens.rename_sharing_token(:readonly, page.readonly_sharing_token)
      assert true
    end

    it "should return an error if you try to modify a bogus token type" do
      page = create_page_with_name "the-page"
      result = PageSharingTokens.new(@page).rename_sharing_token(
        :bogus, "too")
      assert_equal :token_type_does_not_exist, result
    end

  end

end
