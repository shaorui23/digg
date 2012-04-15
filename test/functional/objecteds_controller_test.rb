require 'test_helper'

class ObjectedsControllerTest < ActionController::TestCase
  setup do
    @objected = objecteds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:objecteds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create objected" do
    assert_difference('Objected.count') do
      post :create, objected: @objected.attributes
    end

    assert_redirected_to objected_path(assigns(:objected))
  end

  test "should show objected" do
    get :show, id: @objected
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @objected
    assert_response :success
  end

  test "should update objected" do
    put :update, id: @objected, objected: @objected.attributes
    assert_redirected_to objected_path(assigns(:objected))
  end

  test "should destroy objected" do
    assert_difference('Objected.count', -1) do
      delete :destroy, id: @objected
    end

    assert_redirected_to objecteds_path
  end
end
