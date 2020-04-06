require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should save" do
    user = User.new(username: "test1", password: "test1")
    assert user.save, "user did not save"
  end

  test "should not be able to read password from db" do
    user = User.new(username: "test12", password: "test12")
    user.save
    user_db = User.find_by(username: "test12")
    assert_not_equal user_db.password, "test12", "password accessed from db"
  end
end