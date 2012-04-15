require 'test_helper'

class StringlistsControllerTest < ActionController::TestCase
  setup do
    @stringlist = stringlists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stringlists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stringlist" do
    assert_difference('Stringlist.count') do
      post :create, stringlist: @stringlist.attributes
    end

    assert_redirected_to stringlist_path(assigns(:stringlist))
  end

  test "should show stringlist" do
    get :show, id: @stringlist
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stringlist
    assert_response :success
  end

  test "should update stringlist" do
    put :update, id: @stringlist, stringlist: @stringlist.attributes
    assert_redirected_to stringlist_path(assigns(:stringlist))
  end

  test "should destroy stringlist" do
    assert_difference('Stringlist.count', -1) do
      delete :destroy, id: @stringlist
    end

    assert_redirected_to stringlists_path
  end
end
