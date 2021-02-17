[![Build Status](https://www.travis-ci.com/jibidus/model_validation.svg?branch=main)](https://www.travis-ci.com/jibidus/model_validation)
[![Coverage Status](https://coveralls.io/repos/github/jibidus/model_validation/badge.svg?branch=main)](https://coveralls.io/github/jibidus/model_validation?branch=main)
[![Gem Version](https://badge.fury.io/rb/model_validator.svg)](https://badge.fury.io/rb/model_validator)

# model_validator

This gem can validate database against Active Record validation rules.
This is useful since error may occur when manipulating such data.

## How this can happen?

- when database is modified without through Active Record api
- when migrations modify database

## How this gem can prevent such unexpected error?

It is recommended to use this gem during deployment step:

- restore production database in a staging/preprod/non-production environment
- validate the database
- add missing migrations in case of violations
- repeat validation and fix until there is no more violation
- then, you are ready to deploy your application in production

## Limitations

This gem fetch **all** record in database, and, for each record run the Active Record validation.
So, because of performances reason, this is only acceptable for tiny databases (thousand of records).

## Installation

Add this line to your application"s Gemfile:

```ruby
gem "model_validator"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install model_validator
```

## Rake task usage

Run `rails db:validate` to validate database of current environment. This is a rake task (see `Rails -T db:validate`)

You can skip some model with `MODEL_VALIDATOR_SKIPPED_MODELS` env var (ex: `DB_VALIDATE_SKIP=Model1,Model2`).

## Ruby usage

Validation engine can also be used anywhere in your code:

```ruby
require "model_validator"
ModelValidator.validate_all
```

This will skip `ModelA` and `Model2` for validation:

```ruby
ModelValidator.validate_all skipped_models: [Model1,Model2]
```

## Development

After checking out the repo, run `make install` to install dependencies.

Then, run `make test` to run the tests (test coverage is available in `coverage/index.html`).

Then, run `make lint` to run linters ([rubocop](https://github.com/rubocop-hq/rubocop)).

To install this gem onto your local machine, run `make install-locally`.

### How to release new version?

Make sure your are in `main` branch. Then, run:
```bash
rake release:make[major|minor|patch|x.y.z]
```

Example for building a new minor release: `rake release:make[minor]`

## Why not contributing to existing gem?

Many already existing gems may do the same, but none are satisfying:

- [validb](https://github.com/jgeiger/validb): depends on [sidekiq](https://github.com/mperham/sidekiq)
- [validates_blacklist](https://www.rubydoc.info/gems/validates_blacklist/0.0.1): requires to add configuration in each model 😨
- [valid_items](https://rubygems.org/gems/valid_items): requires rails eager load 🤔
- [schema-validations](https://github.com/robworley/schema-validations): I don"t understand what it really does 🤪

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jibidus/model_validator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/model_validator/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ModelValidator project"s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/model_validator/blob/master/CODE_OF_CONDUCT.md).
