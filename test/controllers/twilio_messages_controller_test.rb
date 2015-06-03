require 'test_helper'

class TwilioMessagesControllerTest < ActionController::TestCase
  setup do
    @twilio_message = twilio_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twilio_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twilio_message" do
    assert_difference('TwilioMessage.count') do
      post :create, twilio_message: { account_sid: @twilio_message.account_sid, body: @twilio_message.body, conversation_count: @twilio_message.conversation_count, date_created: @twilio_message.date_created, date_sent: @twilio_message.date_sent, date_updated: @twilio_message.date_updated, direction: @twilio_message.direction, error_code: @twilio_message.error_code, error_message: @twilio_message.error_message, from: @twilio_message.from, from_city: @twilio_message.from_city, from_state: @twilio_message.from_state, from_zip: @twilio_message.from_zip, message_sid: @twilio_message.message_sid, status: @twilio_message.status, to: @twilio_message.to, wufoo_formid: @twilio_message.wufoo_formid }
    end

    assert_redirected_to twilio_message_path(assigns(:twilio_message))
  end

  test "should show twilio_message" do
    get :show, id: @twilio_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twilio_message
    assert_response :success
  end

  test "should update twilio_message" do
    patch :update, id: @twilio_message, twilio_message: { account_sid: @twilio_message.account_sid, body: @twilio_message.body, conversation_count: @twilio_message.conversation_count, date_created: @twilio_message.date_created, date_sent: @twilio_message.date_sent, date_updated: @twilio_message.date_updated, direction: @twilio_message.direction, error_code: @twilio_message.error_code, error_message: @twilio_message.error_message, from: @twilio_message.from, from_city: @twilio_message.from_city, from_state: @twilio_message.from_state, from_zip: @twilio_message.from_zip, message_sid: @twilio_message.message_sid, status: @twilio_message.status, to: @twilio_message.to, wufoo_formid: @twilio_message.wufoo_formid }
    assert_redirected_to twilio_message_path(assigns(:twilio_message))
  end

  test "should destroy twilio_message" do
    assert_difference('TwilioMessage.count', -1) do
      delete :destroy, id: @twilio_message
    end

    assert_redirected_to twilio_messages_path
  end
end
