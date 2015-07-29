# Sidekiq::Statistic

[![Build Status](https://travis-ci.org/davydovanton/sidekiq-statistic.svg)](https://travis-ci.org/davydovanton/sidekiq-statistic) [![Code Climate](https://codeclimate.com/github/davydovanton/sidekiq-history/badges/gpa.svg)](https://codeclimate.com/github/davydovanton/sidekiq-history) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/davydovanton/sidekiq-history?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Improved display of statistics for your sidekiq workers and jobs.

**This gem work only with sidekiq version more than [3.3.4](https://github.com/mperham/sidekiq/releases/tag/v3.3.4)**

**This not production version of gem**

## Screenshots

Also you can check <a href="https://sidekiq-history-gem.herokuapp.com/sidekiq/statistic" target="_blank">heroku application</a> with this plugn 
### Index page:
![sidekiq-history_index](https://cloud.githubusercontent.com/assets/1147484/8071172/1708e3b0-0f10-11e5-84cf-86a910f5ecc2.png)

### Worker page with table (per day):
![sidekiq-history_worker](https://cloud.githubusercontent.com/assets/1147484/8071171/1706924a-0f10-11e5-9ddc-8aeeb7f5c794.png)

### Worker page with log:
![screenshot 2015-06-10 01 27 50](https://cloud.githubusercontent.com/assets/1147484/8071166/0edd7688-0f10-11e5-9841-0572ab5704e3.jpg)

## Installation
Add this line to your application's Gemfile:

    gem 'sidekiq-statistic', github: 'davydovanton/sidekiq-history'

And then execute:

    $ bundle

## Usage
Open in your browser `/sidekiq/statistic` page.

## Configuration
Sidekiq statistic gem have `log_file` option. This option lets you specify a custom path to sidekiq log file. By default this option equal `log/sidekiq.log`

``` ruby
Sidekiq::Statistic.configure do |config|
  config.log_file = 'test/helpers/logfile.log'
end
```

## How it works
![how-it-works](https://cloud.githubusercontent.com/assets/1147484/8802272/fc0a1302-2fc8-11e5-86a5-817409259338.png)

## Contributing
1. Fork it ( https://github.com/davydovanton/sidekiq-statistic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
