require 'bundler/capistrano'
require 'capistrano_colors'

set :application, "churchdirectory"
set :deploy_to, "/home/www/churchdirectory"

default_run_options[:pty] = true

set :scm, :git
set :deploy_via, :remote_cache
set :repository, "git@github.com:tiostech/tios-core.git"

set :user, "apache"
set :use_sudo, false

role :web, "www.thefujitos.com"
role :db, "www.thefujitos.com"
role :app, "www.thefujitos.com"

namespace :assets do
  task :precompile, :roles => :web, :except => { :no_release => true } do
    from = source.next_revision(current_revision) rescue nil
    if from.nil? || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
      run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
    else
      logger.info "Skipping asset pre-compilation because there were no asset changes"
    end
  end
end

# Passenger stuff
namespace :deploy do
 task :start do ; end
 task :stop do ; end
 task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
 end
end