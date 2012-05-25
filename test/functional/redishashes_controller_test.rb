require 'test_helper'

class RedishashesControllerTest < ActionController::TestCase
  setup do
    @redishash = redishashes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:redishashes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create redishash" do
    assert_difference('Redishash.count') do
      post :create, redishash: @redishash.attributes
    end

    assert_redirected_to redishash_path(assigns(:redishash))
  end

  test "should show redishash" do
    get :show, id: @redishash
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @redishash
    assert_response :success
  end

  test "should update redishash" do
    put :update, id: @redishash, redishash: @redishash.attributes
    assert_redirected_to redishash_path(assigns(:redishash))
  end

  test "should destroy redishash" do
    assert_difference('Redishash.count', -1) do
      delete :destroy, id: @redishash
    end

    assert_redirected_to redishashes_path
  end
end
