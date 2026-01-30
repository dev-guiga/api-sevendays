# frozen_string_literal: true

json.success true
json.schedulings @schedulings do |s|
  json.id s.id
  json.date s.date
  json.time s.time
  json.status s.status
end
