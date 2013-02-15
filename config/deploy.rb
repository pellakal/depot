require 'bundler/capistrano'
set :user, 'pellakal'
set :domain, 'depot.prod'
set :application, 'depot'

require "rvm/capistrano"
set :rvm_ruby_string, '1.9.3'
set :rvm_type, :user

ssh_options[:forward_agent] = true

# file paths
set :repository,  "git@github.com:pellakal/depot.git" 
set :deploy_to, "/home/pellakal/prod/#{domain}" 

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, :production

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; \
      rake db:seed RAILS_ENV=#{rails_env}"
  end
end

desc "copy shared/database.yml to current/config/database.yml"
task :copy_database_yml do
  run "ln -fs #{shared_path}/database.yml #{current_path}/config/database.yml"
end

after 'deploy:create_symlink', 'copy_database_yml'
