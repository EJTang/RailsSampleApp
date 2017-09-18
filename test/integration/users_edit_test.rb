require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@user = users(:micheal)
  end

  test "unsuccessful edit" do
  	log_in_as(@user)
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	patch user_path(@user), params: { user: { name: 				"",
  											email: 					"foo@invalid",
  											password: 				"foo",
  											password_confirmation: 	"bar" } }
  	assert_template 'users/edit'
  end

  test "should have 2 errors" do
  	log_in_as(@user)
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	patch user_path(@user), params: { user: { name: 				"",
  											email: 					"foo@invalid",
  											password: 				"foobar",
  											password_confirmation: 	"foobar" } }
  	assert_template 'users/edit'
  	assert_select "div.alert", "The form contains 2 errors."
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
  	log_in_as(@user)
  	assert_redirected_to edit_user_url(@user)
  	name = "Foo Bar"
  	email = "foo@bar.com"
  	patch user_path(@user), params: { user: { 	name: 					name,
  												                      email: 					email,
												                        password: 				"",
												                        password_confirmation: 	""} }
	 assert_not flash.empty?
	 assert_redirected_to @user
	 @user.reload
	 assert_equal name, @user.name
	 assert_equal email, @user.email
  end

  test "only friendly forwards the first time" do
    get edit_user_path(@user)
    assert_not session[:forwarding_url].empty?
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    delete logout_path
    assert session[:forwarding_url].nil?
    log_in_as(@user)
    assert_redirected_to @user
  end
end
