require 'test_helper'

class GithubOauthControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get initialize" do
    get :initialize
    assert_response :success
  end

  test "should get finalize" do
    get :finalize
    assert_response :success
  end

end
