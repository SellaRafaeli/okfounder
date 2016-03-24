$users = $mongo.collection('users')


USERS_GOOGLE_DOC_URI = "https://spreadsheets.google.com/feeds/list/1qnAoR2o0yZvrkQlCayyxhjyvZNI2ycALmP4ipUDkka8/1/public/values?alt=json"

WHITE_USER_PARAMS = [:name,:desc,:age]

def create_user(data)   
  $users.add(data)
end

def get_users(crit = {}, opts = {})
  users = $users.find(crit).limit(10).to_a  
  {users: users}
end

# GET http://okfounder.herokuapp.com/users
get '/users/all' do
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

# curl -d "code=123&desc=loves Jerusalem" http://okfounder.herokuapp.com/users/update
post '/users/update' do
  set_data = params.just(WHITE_USER_PARAMS)
  $users.update_one({code: params[:code]},"$set" => set_data)
  get_users({code: params[:code]})
end

def user_fields_hash
  mapping = {
    email: 'contactemailwewillneveremailyouanything',
    name: 'venturename',
    city: 'city',
    description: 'descriptionwhatisyourventurehelpusunderstandyourventuretrytowriteacoupleparagraphsexplainingwhatyouaredoing.',
    looking_for: 'whatareyoulookingfor',
    specifically_looking_for: 'specificallywhatwhoareyoulookingfor',
    industry_category: 'industrycategory',
    stage: 'stage',
    funding_stage: 'istheventurefundedhowmuchmoneydoyouhaveinusd',
    num_people_in_venture: 'numberofpeoplealreadyintheventure',
    salary_or_equity: 'offeringsalaryorequity',
    why_you_details: 'whyshouldwecomeworkforyouincludeasmuchinformationasyoucan1.yourlinkedin2.facebookpage3.website4.thenamesandrolesofthepeoplealreadyinvolved5.anythingelsethatmightconvincepeopletoapproachyouincludingrelevantlinks.thisisyourplacetoshine.'
  }
end

def user_frontend_fields
  user_fields_hash.keys
end 

def map_google_doc_fields(google_doc_user)
  mapping = user_fields_hash
  normalized_user = {}
  mapping.each do |new_key,old_key| 
    normalized_user[new_key] = google_doc_user[old_key]
  end

  normalized_user
end

def get_normalized_users
  uri  = USERS_GOOGLE_DOC_URI
  rows = JSON.parse(open(uri).read)['feed']['entry'].map {|row| kvs = row.select {|k,v| k.start_with?('gsx$') } }.map {|row| row = row.map {|k,v| [k.sub('gsx$',''),v['$t'] ]; }.to_h }
  rows.map! {|row| map_google_doc_fields(row) }
end

def update_all_users_from_google_doc
  $users.delete_many
  users = get_normalized_users
  users.each do |u| $users.add(u) end 
  {users: users, count: users.size, keys: user_frontend_fields}
end

get '/users/update_from_google_doc' do
  update_all_users_from_google_doc
end

def facets_crit
  fields = user_frontend_fields
  white_params = params
  #white_params = params.just(fields)
  crit   = white_params.map {|k,v| v = Regexp.new(v, Regexp::IGNORECASE); [k,v] }.to_h
  crit
end

get '/users/facets_crit' do
  facets_crit
end

# GET http://okfounder.herokuapp.com/users/by_facets?name=kar
get '/users/by_facets' do
  crit = facets_crit   
  get_users(crit)
end

# GET http://okfounder.herokuapp.com/users/xUP4CYOAPg
get '/users/:id' do
  get_users(_id: params[:id])
end