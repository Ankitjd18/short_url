require 'test_helper'

class MiniUrlTest < ActiveSupport::TestCase

  test "should not save without url_code" do
    mini_url = MiniUrl.new
    mini_url.url = "https://www.google.com/"
    assert_not mini_url.save, "Saved mini_url without url_code"
  end

  test "should not save without url" do
    mini_url = MiniUrl.new
    mini_url.url_code = SecureRandom.alphanumeric(8)
    assert_not mini_url.save, "Saved mini_url without url"
  end

  test "should save" do
    mini_url = MiniUrl.new
    mini_url.url_code = SecureRandom.alphanumeric(8)
    mini_url.url = "https://www.google.com/"
    assert mini_url.save, "mini_url not saved"
  end

  test "should not save with duplicate url_code" do
    url_code = SecureRandom.alphanumeric(8)
    mini_url = MiniUrl.new
    mini_url.url_code = url_code
    mini_url.url = "https://www.google.com/"
    mini_url.save
    mini_url_dup = MiniUrl.new
    mini_url_dup.url_code = url_code
    mini_url_dup.url = "https://www.netflix.com/browse"
    assert_not mini_url_dup.save, "Saved with duplicate url_code"
  end

  test "should save with optional fields too" do
    mini_url = MiniUrl.new
    mini_url.url_code = SecureRandom.alphanumeric(8)
    mini_url.url = "https://www.google.com/"
    mini_url.expiry = DateTime.now + 1.day
    assert mini_url.save, "mini_url not saved with optional fields"
  end
end