require_relative "../../spec_helper"

describe Page do

  before do
    $data_store = get_memory_datastore()
  end

  def create_page_with_name name
    Page.create name:name, text:"foo"
  end

  describe "creation" do

    it "should make a page" do
      page = create_page_with_name "good"
      assert_equal page.name, "good"
    end

  end

  describe "updating" do

    it "should update the revision number" do
      page = create_page_with_name "good"
      assert_equal 0, page.revision

      page.text = "new text 1"
      page.save

      page = Page.find(1)
      assert_equal "new text 1", page.text
      assert_equal 1, page.revision

      page.text = "new text 2"
      page.save

      page = Page.find(1)
      assert_equal "new text 2", page.text
      assert_equal 2, page.revision
    end

  end

  describe "deletion" do

    it "should delete a page" do
      create_page_with_name "good"
      page = Page.find(1)
      assert_equal 1, page.id

      page.virtual_delete()
      assert_nil Page.find(1)
    end

  end

end
