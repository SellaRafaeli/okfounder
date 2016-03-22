$users = $mongo.collection('users')

WHITE_USER_PARAMS = [:name,:desc,:age]

def create_user(data)   
  $users.add(data)
end

def get_users(crit = {}, opts = {})
  users = $users.find(crit).limit(10).to_a  
  {users: users}
end

get '/users' do
  crit = {}
  get_users(crit)
end

get '/users/search' do
  query = params[:query].to_s
  crit = crit_any_field($users,query)
  get_users(crit)
end

post '/users/create' do
  data = params.just(WHITE_USER_PARAMS)
  data[:code] = SecureRandom.uuid
  create_user(data)
end

post '/users/update' do
  set_data = params.just(WHITE_USER_PARAMS)
  $users.update({code: params[:code]},set_data)
end


# http://localhost:9292/users/HaSlQ6nrvg
get '/users/:id' do
  get_users(_id: params[:id])
end