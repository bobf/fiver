include orchestration/Makefile
#
# Example test command
#
# This command will call `test-setup` before running your usual test pipeline.
#
# `test-setup` starts all containers specified in `docker-compose.test.yml`,
# waits for them to be ready, and runs DB migrations.
#
# In your CI environment, simply run `make test`.
#
.PHONY: test
test: test-setup
	bundle exec rspec
	bundle exec rubocop
	bundle exec strong_versions
	bundle exec brakeman

# Start development containers and create/migrate/seed database
.PHONY: develop
develop:
	bundle install
	@$(MAKE) start env=test
	@$(MAKE) start env=development
	bundle exec rake db:create
	bundle exec rake db:migrate
	bundle exec rake db:seed
