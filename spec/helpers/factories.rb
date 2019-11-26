module Factories

  def create_user(refuge_id, slack_id = nil)
    Corbot::User.create(
      refuge_user_id: refuge_id,
      refuge_user_first_name: 'Foo',
      refuge_user_last_name: 'Bar',
      slack_user_id: slack_id
    )
  end

end