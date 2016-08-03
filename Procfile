redis: redis-server
pet_svc: rackup pet_service/config.ru -p 4000
arena_svc: rackup arena_service/config.ru -p 5000
worker: bundle exec sidekiq -r ./contest_worker/init.rb -c 2
