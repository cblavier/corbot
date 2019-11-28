module Factories

  def create_user(
    refuge_user_id,
    refuge_user_first_name: "Foo",
    refuge_user_last_name: "Foo",
    slack_user_id: nil,
    admin: false,
    ignored: false,
    removed: false,
    bound_at: nil
  )
    Corbot::User.create(
      refuge_user_id: refuge_user_id,
      refuge_user_first_name: refuge_user_first_name,
      refuge_user_last_name: refuge_user_last_name,
      slack_user_id: slack_user_id,
      admin: admin,
      ignored: ignored,
      removed: removed,
      bound_at: bound_at
    )
  end

end