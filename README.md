# Sidekiq::History

[![Build Status](https://travis-ci.org/davydovanton/sidekiq-history.svg?branch=master)](https://travis-ci.org/davydovanton/sidekiq-history) [![Code Climate](https://codeclimate.com/github/davydovanton/sidekiq-history/badges/gpa.svg)](https://codeclimate.com/github/davydovanton/sidekiq-history) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/davydovanton/sidekiq-history?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Improved display of statistics for your sidekiq workers and jobs.

**This gem work only with sidekiq version more than [3.3.4](https://github.com/mperham/sidekiq/releases/tag/v3.3.4)**

**This not production version of gem**

## Screenshots
### Index page:
![sidekiq-history_index](https://cloud.githubusercontent.com/assets/1147484/8071172/1708e3b0-0f10-11e5-84cf-86a910f5ecc2.png)

### Worker page with table (per day):
![sidekiq-history_worker](https://cloud.githubusercontent.com/assets/1147484/8071171/1706924a-0f10-11e5-9ddc-8aeeb7f5c794.png)

### Worker page with log:
![screenshot 2015-06-10 01 27 50](https://cloud.githubusercontent.com/assets/1147484/8071166/0edd7688-0f10-11e5-9841-0572ab5704e3.jpg)

## Installation
Add this line to your application's Gemfile:

    gem 'sidekiq_history', github: 'davydovanton/sidekiq-history'

And then execute:

    $ bundle

## Usage
Open in your browser `/sidekiq/history` page.

## Configuration
Sidekiq history gem have `log_file` option. This option lets you specify a custom path to sidekiq log file. By default this option equal `log/sidekiq.log`

``` ruby
Sidekiq::History.configure do |config|
  config.log_file = 'test/helpers/logfile.log'
end
```

## Contributing
1. Fork it ( https://github.com/davydovanton/sidekiq-history/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
