json.user do
  json.id user.id
  json.first_name user.first_name
  json.last_name user.last_name
  json.full_name user.full_name
  json.username user.username
  json.email user.email
  json.status user.status
  json.created_at user.created_at
  json.updated_at user.updated_at
  json.cpf user.cpf
  json.address user.address
  json.city user.city
  json.state user.state
  json.neighborhood user.neighborhood
  json.birth_date user.birth_date
end
