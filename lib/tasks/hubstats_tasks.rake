# A variety of commands that can be used to populate the database information
namespace :hubstats do

  desc "Create the database, load the schema, and pull data from Github (use hubstats:reset to also drop the db first)"
  task :setup => :environment do
    puts "Running rake db:create"
    Rake::Task['db:create'].invoke
    puts "Running rake db:migrate"
    Rake::Task['db:migrate'].invoke
    puts "Pulling data from Github. This may take a while..."
    Rake::Task['hubstats:populate:setup_repos'].invoke
    Rake::Task['hubstats:populate:setup_teams'].invoke
  end

  desc "Drops the database, then runs rake hubstats:setup"
  task :reset => :environment do
    puts "Dropping Database"
    Rake::Task['db:drop'].invoke
    Rake::Task['hubstats:setup'].invoke
  end

  desc "Updates changes to the config file"
  task :update => :environment do
    puts "Updating repos"
    Rake::Task['hubstats:populate:update_repos'].invoke
  end

  desc "Updates the seed"
  task :seed => :environment do
    puts "Updating seed"
    Rake::Task['db:seed'].invoke
  end

  desc "Updates the teams for past pull requests"
  task :update_teams_in_pulls => :environment do
    puts "Updating teams for past pull requests"
    Rake::Task['hubstats:populate:update_teams_in_pulls'].invoke
  end

  desc "Updates the teams"
  task :update_teams => :environment do
    puts "Updating teams"
    Rake::Task['hubstats:populate:update_teams'].invoke
  end

  desc "Deprecates teams based on the octokit.yml file"
  task :deprecate_teams_from_file => :environment do
    puts "Deprecating teams based on whitelist in octokit.yml"
    Rake::Task['hubstats:populate:deprecate_teams_from_file'].invoke
  end

  desc "Creates webhook from github for organization"
  task :make_org_webhook => :environment do
    puts "Making a webhook for an organization in octokit.yml"
    Rake::Task['hubstats:populate:setup_teams'].invoke
  end

  desc "Updates webhooks from github for repositories"
  task :update_repo_webhooks => :environment do
    puts "Updating webhooks for repositories in octokit.yml"
    Rake::Task['hubstats:populate:update_hooks'].invoke
  end

end
