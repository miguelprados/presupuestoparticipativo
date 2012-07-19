namespace :mongodb do
  desc 'Copy a development database to production'
  task push: :environment do
    puts <<-END
 !    WARNING: Destructive Action
 !    Data in the app will be overwritten and will not be recoverable.
 !    To proceed, type "nogoingback"
END
    if STDIN.gets == "nogoingback\n"
      uri = URI.parse `heroku config:get MONGOLAB_URI`.chomp
      puts `mongodump -h localhost -d citizen_budget_development -o dump-dir`.chomp
      puts `mongorestore -h #{uri.host}:#{uri.port} -d #{uri.path.sub '/', ''} -u #{uri.user} -p #{uri.password} dump-dir/*`.chomp
    else
      puts 'Confirmation did not match "nogoingback". Aborted.'
    end
  end

  desc 'Copy a production database to development'
  task pull: :environment do
    uri = URI.parse `heroku config:get MONGOLAB_URI`.chomp
    puts `mongodump -h #{uri.host}:#{uri.port} -d #{uri.path.sub '/', ''} -u #{uri.user} -p #{uri.password} -o dump-dir`.chomp
    puts `rm -f dump-dir#{uri.path}/system.*`.chomp # MongoLab adds system collections, which we don't need.
    puts `mongorestore -h localhost -d citizen_budget_development --drop dump-dir/*`.chomp
  end
end
