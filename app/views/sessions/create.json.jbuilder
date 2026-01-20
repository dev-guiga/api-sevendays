json.success true
json.user do
  json.id @user.id
    json.name @user.full_name
    json.username @user.username
  json.email @user.email_address
  json.status @user.status
end
