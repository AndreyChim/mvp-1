email: 'admin@example.com',
password: 'password',

run by docker:

docker-compose down -v
docker-compose build --no-cache
docker-compose up

if you got an error:  ActiveRecord::PendingMigrationError 
you need to run in another terminal window:

docker-compose run web bundle exec rails db:migrate
docker-compose run web bundle exec rails db:seed