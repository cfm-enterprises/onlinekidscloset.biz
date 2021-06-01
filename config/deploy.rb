after "deploy:symlink" do
  bionic_symlink
end
after "deploy", "deploy:cleanup"

set :application, "kidscloset.biz"
set :repository,  "git@github.com:cfm-enterprises/kidscloset.biz.git"
set :scm, :git
set :git_enable_submodules, 1

default_run_options[:pty] = true
set :user, 'deploy'
set :use_sudo, false

set :keep_releases, 3
set :deploy_to, "/home/#{user}/sites/#{application}"

role :web, "173.230.133.42", "23.92.30.103"
role :app, "74.207.231.138"
role :db,  "74.207.231.138", :primary => true

task :production do
  set :branch, "master"
  set :rails_env, "production"
end

task :staging do
  set :branch, "master"
  set :rails_env, "staging"
end

task :bionic_symlink do
  run <<-CMD
    cd #{release_path} &&
    ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml &&
    ln -nfs /home/deploy/mount/#{application}/assets #{release_path}/public/assets
  CMD
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :web, :except => { :no_release => true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end