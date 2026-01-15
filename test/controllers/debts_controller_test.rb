require "test_helper"

class DebtsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get debts_index_url
    assert_response :success
  end

  test "should get create" do
    get debts_create_url
    assert_response :success
  end

  test "should get destroy" do
    get debts_destroy_url
    assert_response :success
  end
end
