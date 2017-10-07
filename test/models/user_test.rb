require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = User.new(name: "Example User", email: "user@example.com",
  					password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do 
  	@user.name = "     "
  	assert_not @user.valid?
  end

  test "email should be present" do 
  	@user.email = "         "
  	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "a" * 244 + "@examaple.com"
  	assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
  	valid_address = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org 
  						first.last@foo.jp alice+bob@bax.cn]
  	valid_address.each do |valid_address|
  		@user.email = valid_address
  		assert @user.valid?, "#{valid_address.inspect} should be valid"
  	end
  end

  test "email validation should reject invalid addresses" do 
  	invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
  							food@bar_baz.com foo@bar+baz.com foo@bar..com]
  	invalid_addresses.each do |invalid_address|
  		@user.email = invalid_addresses
  		assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
  	end
  end

  test "email address should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = @user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
  	@user.password = @user.password_confirmation = " "  * 6
  	assert_not @user.valid?
  end

  test "password should have a minimum length" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

  test "authenticated? should return ralse for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    micheal = users(:micheal)
    archer = users(:archer)
    assert_not micheal.following?(archer)
    micheal.follow(archer)
    assert micheal.following?(archer)
    assert archer.followers.include?(micheal)
    micheal.unfollow(archer)
    assert_not micheal.following?(archer)
  end

  test "feed should have the right posts" do
    micheal = users(:micheal)
    archer = users(:archer)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert micheal.feed.include?(post_following)
    end
    # Posts from self
    micheal.microposts.each do |post_self|
      assert micheal.feed.include?(post_self)
    end
    # Post from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not micheal.feed.include?(post_unfollowed)
    end
  end

end
