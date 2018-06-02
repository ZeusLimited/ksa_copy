set :application, 'ksazd'
set :stage, :production
set :rails_env, "production"

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w{10.101.102.130}
role :web, %w{10.101.102.130}
role :db,  %w{10.101.102.130}

set :deploy_to, -> { "/app/apps/#{fetch(:application)}" }

set :bundle_env_variables, {
  'http_proxy' => 'http://ksadz_user:Ksf5310@inetm9.corp.gidroogk.com:8080',
  'https_proxy' => 'http://ksadz_user:Ksf5310@inetm9.corp.gidroogk.com:8080',
}

# set :repo_url, 'https://ksazd-deployer:QazxsW5678901234@github.com/LtdArink-Group/ksazd.git'

server '10.101.102.130', user: fetch(:user), roles: %w{web app}
set :branch, "master"

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

# fetch(:default_env).merge!(rails_env: :staging)
