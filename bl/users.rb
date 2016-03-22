$users = $mongo.collection('users')

WHITE_USER_PARAMS = [:name,:desc,:age]

def create_user(data)   
  $users.add(data)
end

def get_users(crit = {}, opts = {})
  users = $users.find(crit).limit(10).to_a  
  {users: users}
end

# GET http://okfounder.herokuapp.com/users
get '/users' do
  crit = {}
  get_users(crit)
end

# GET http://okfounder.herokuapp.com/users/search?query=jeru
get '/users/search' do
  query = params[:query].to_s
  crit = crit_any_field($users,query)
  get_users(crit)
end

# curl -d "name=David" http://okfounder.herokuapp.com/users/create
post '/users/create' do
  data = params.just(WHITE_USER_PARAMS)
  data[:code] = SecureRandom.uuid
  create_user(data)
  get_users({code: data[:code]})
end

# curl -d "code=d873c798-860c-4293-acc1-ae0f06429c7f&desc=currently lives in Jerusalem" http://okfounder.herokuapp.com/users/update
post '/users/update' do
  set_data = params.just(WHITE_USER_PARAMS)
  $users.update_one({code: params[:code]},"$set" => set_data)
  get_users({code: params[:code]})
end

# GET http://okfounder.herokuapp.com/users/xUP4CYOAPg
get '/users/:id' do
  get_users(_id: params[:id])
end