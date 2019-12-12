require 'test_helper'

class ActivityTypesApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include TestHelpers::AuthHelper
  include TestHelpers::JsonHelper

  def app
    Rails.application
  end

  # GET tests
  # Get all activity types' details
  def test_get_all_activity_types
    get '/api/activity_types'
    expected_data = ActivityType.all

    assert_equal expected_data.count, last_response_body.count

    response_keys = %w(name abbreviation)

    last_response_body.each do | data |
      activity_type = ActivityType.find(data['id'])
      assert_json_matches_model(data, activity_type, response_keys)
    end
  end

  # Get an activity type's details
  def test_get_an_activity_type_details
    expected_at = ActivityType.second

    # perform the GET 
    get "/api/activity_types/#{expected_at.id}"
    returned_tp = last_response_body

    # Check if the call succeeds
    assert_equal 200, last_response.status
    
    # Check the returned details match as expected
    response_keys = %w(name abbreviation)
    assert_json_matches_model(returned_tp, expected_at, response_keys)
  end

  # POST tests
  # Post an activity type
  def test_post_activity_types
    data_to_post = {
      activity_type: FactoryGirl.build(:activity_type),
      auth_token: auth_token
    }
    post_json '/api/activity_types', data_to_post
    assert_equal 201, last_response.status

    response_keys = %w(name abbreviation)
    activity_type = ActivityType.find(last_response_body['id'])
    assert_json_matches_model(last_response_body, activity_type, response_keys)
  end

  # PUT tests
  # Put an activity type
  def test_put_activity_types
    data_to_put = {
      activity_type: FactoryGirl.build(:activity_type),
      auth_token: auth_token
    }

    # Update activity_type with id = 1
    put_json '/api/activity_types/1', data_to_put
    assert_equal 200, last_response.status

    response_keys = %w(name abbreviation)
    first_activity_type = ActivityType.first
    assert_json_matches_model(last_response_body, first_activity_type, response_keys)
  end

  # DELETE tests
  # Delete an activity type
def test_delete_an_activity_type
    number_of_at = ActivityType.count

    data_to_post = {
      activity_type: FactoryGirl.build(:activity_type),
      auth_token: auth_token
    }
    post_json '/api/activity_types', data_to_post

    assert_equal ActivityType.count, number_of_at + 1

    new_activity_type = ActivityType.last

    assert ActivityType.exists?(new_activity_type.id)

    delete_json with_auth_token"/api/activity_types/#{new_activity_type.id}"

    assert_equal ActivityType.count, number_of_at

    refute ActivityType.exists?(new_activity_type.id)
  end

  # Delete a activity type using unauthorised account
  def test_student_delete_activity_type
    user = FactoryGirl.build(:user, :student)

    number_of_at = ActivityType.count

    activity_type = ActivityType.second
    id_of_at = activity_type.id

    # perform the delete
    delete_json with_auth_token("/api/activity_types/#{id_of_at}", user)

    # check if the delete does not get through
    assert_equal 403, last_response.status

    # check if the number of activity type is still the same
    assert_equal ActivityType.count, number_of_at

    # Check that you still can find the deleted id
    assert ActivityType.exists?(id_of_at)
  end

end
