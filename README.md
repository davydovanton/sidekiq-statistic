# Sidekiq statistic

[![Build Status](https://travis-ci.org/davydovanton/sidekiq-statistic.svg)](https://travis-ci.org/davydovanton/sidekiq-statistic) [![Code Climate](https://codeclimate.com/github/davydovanton/sidekiq-history/badges/gpa.svg)](https://codeclimate.com/github/davydovanton/sidekiq-history) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/davydovanton/sidekiq-history?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Improved display of statistics for your sidekiq workers and jobs.

**This gem work only with sidekiq version more than [3.3.4](https://github.com/mperham/sidekiq/releases/tag/v3.3.4)**

## Screenshots
Also you can check <a href="https://sidekiq-history-gem.herokuapp.com/sidekiq/statistic" target="_blank">heroku application</a> with rails app with this sidekiq plugin

### Index page:
![sidekiq-history_index](https://cloud.githubusercontent.com/assets/1147484/8071172/1708e3b0-0f10-11e5-84cf-86a910f5ecc2.png)

### Worker page with table (per day):
![sidekiq-history_worker](https://cloud.githubusercontent.com/assets/1147484/8071171/1706924a-0f10-11e5-9ddc-8aeeb7f5c794.png)

### Worker page with log:
![screenshot 2015-06-10 01 27 50](https://cloud.githubusercontent.com/assets/1147484/8071166/0edd7688-0f10-11e5-9841-0572ab5704e3.jpg)

## Installation
Add this line to your application's Gemfile:

    gem 'sidekiq-statistic'

And then execute:

    $ bundle

## Usage
Open Statistic tab on your sidekiq page.

### Not rails application
Read [sidekiq documentation](https://github.com/mperham/sidekiq/wiki/Monitoring#standalone).
After that add `require 'sidekiq-statistic'` to you `config.ru`. For example:
``` ruby
# config.ru
require 'sidekiq/web'
require 'sidekiq-statistic'

use Rack::Session::Cookie, secret: 'some unique secret string here'
Sidekiq::Web.instance_eval { @middleware.reverse! } # Last added, First Run
run Sidekiq::Web
```

## Configuration
Sidekiq statistic gem have `log_file` option. This option lets you specify a custom path to sidekiq log file. By default this option equal `log/sidekiq.log`

``` ruby
Sidekiq::Statistic.configure do |config|
  config.log_file = 'test/helpers/logfile.log'
end
```

## JSON API
### /api/statistic.json
Returns statistic for each worker.

Params:
  * `dateFrom` - Date start (format: `yyyy-mm-dd`)
  * `dateTo` - Date end (format: `yyyy-mm-dd`)

Example:
```
$ curl http://example.com/sidekiq/api/statistic.json?dateFrom=2015-07-30&dateTo=2015-07-31

# =>
  {
    "workers": [
      {
        "name": "Worker",
        "last_job_status": "passed",
        "number_of_calls": {
          "success": 1,
          "failure": 0,
          "total": 1
        },
        "runtime": {
          "last": "2015-07-31 10:42:13 UTC",
          "max": 4.002,
          "min": 4.002,
          "average": 4.002,
          "total": 4.002
        }
      },

      ...
    ]
  }
```

### /api/statistic/:worker_name.json
Returns worker statistic for each day in range.

Params:
  * `dateFrom` - Date start (format: `yyyy-mm-dd`)
  * `dateTo` - Date end (format: `yyyy-mm-dd`)

Example:
```
$ curl http://example.com/sidekiq/api/statistic/Worker.json?dateFrom=2015-07-30&dateTo=2015-07-31

# =>
{
  "days": [
    {
      "date": "2015-07-31",
      "failure": 0,
      "success": 1,
      "total": 1,
      "last_job_status": "passed",
      "runtime": {
        "last": null,
        "max": 0,
        "min": 0,
        "average": 0,
        "total": 0
      }
    },

    ...
  ]
}
```

## Update statistic inside middleware
You can update your worker statistic inside middleware. For this you should to update `sidekiq:statistic` redis hash.
This hash has the following structure:
* `sideki:statistic` - redis hash with all statistic
  - `yyyy-mm-dd:WorkerName:passed` - count of passed jobs for Worker name on yyyy-mm-dd
  - `yyyy-mm-dd:WorkerName:failed` - count of failed jobs for Worker name on yyyy-mm-dd
  - `yyyy-mm-dd:WorkerName:failed` - count of failed jobs for Worker name on yyyy-mm-dd
  - `yyyy-mm-dd:WorkerName:last_job_status` - string with status (`passed` or `failed`) for last job
  - `yyyy-mm-dd:WorkerName:last_time` - date of lact job performing
  - `yyyy-mm-dd:WorkerName:queue` - name of job queue (`defauld` by default)

For time information you should push the runtime value to `yyyy-mm-dd:WorkerName:timeslist` redis list.

## How it works
![how-it-works](https://cloud.githubusercontent.com/assets/1147484/8802272/fc0a1302-2fc8-11e5-86a5-817409259338.png)

## Contributing
1. Fork it ( https://github.com/davydovanton/sidekiq-statistic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
