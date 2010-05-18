require File.dirname(__FILE__) + '/../test_helper'
require 'recryptrequests_controller'

# Re-raise errors caught by the controller.
class RecryptrequestsController; def rescue_action(e) raise e end; end

class RecryptrequestsControllerTest < ActiveSupport::TestCase
  fixtures :recryptrequests

  def setup
    @controller = RecryptrequestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = recryptrequests(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:recryptrequests)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:recryptrequest)
    assert assigns(:recryptrequest).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:recryptrequest)
  end

  def test_create
    num_recryptrequests = Recryptrequest.count

    post :create, :recryptrequest => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_recryptrequests + 1, Recryptrequest.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:recryptrequest)
    assert assigns(:recryptrequest).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Recryptrequest.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Recryptrequest.find(@first_id)
    }
  end
end
