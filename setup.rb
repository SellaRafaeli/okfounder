$app_name   = 'okfounder'

$prod       = settings.production? #RACK_ENV==production?
$prod_url   = 'http://my-er.herokuapp.com/'
$root_url   = $prod ? $prod_url : 'http://localhost:9000'

enable :sessions
enable :cross_origin

set :raise_errors,          false
set :show_exceptions,       false
set :erb, :layout =>    false

def bp
  binding.pry
end

def get_fullpath
  $root_url + request.fullpath
end