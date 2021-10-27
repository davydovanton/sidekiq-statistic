
# Sidekiq::Statistic

[![Build Status](https://travis-ci.org/davydovanton/sidekiq-statistic.svg)](https://travis-ci.org/davydovanton/sidekiq-statistic) [![Code Climate](https://codeclimate.com/github/davydovanton/sidekiq-history/badges/gpa.svg)](https://codeclimate.com/github/davydovanton/sidekiq-history) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/davydovanton/sidekiq-history?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Improved display of statistics for your Sidekiq workers and jobs.

## Screenshots

### Index page:
![sidekiq-history_index](https://user-images.githubusercontent.com/15057257/66249364-74645d80-e708-11e9-8f06-a9a224be4e37.png)

### Worker page with table (per day):
![sidekiq-history_worker](https://cloud.githubusercontent.com/assets/1147484/8071171/1706924a-0f10-11e5-9ddc-8aeeb7f5c794.png)

## Installation
Add this line to your application's Gemfile:

    gem 'sidekiq-statistic'

And then execute:

    $ bundle

## Usage

### Using Rails

Read [Sidekiq documentation](https://github.com/mperham/sidekiq/wiki/Monitoring#rails) to configure Sidekiq Web UI in your `routes.rb`.

When Sidekiq Web UI is active you're going be able to see the option `Statistic` on the menu.

### Using a standalone application

Read [Sidekiq documentation](https://github.com/mperham/sidekiq/wiki/Monitoring#standalone) to configure Sidekiq in your Rack server.

Next add `require 'sidekiq-statistic'` to your `config.ru`.

``` ruby
# config.ru
require 'sidekiq/web'
require 'sidekiq-statistic'

use Rack::Session::Cookie, secret: 'some unique secret string here'
run Sidekiq::Web
```

## Configuration

The Statistic configuration is an initializer that GEM uses to configure itself. The option `max_timelist_length`
is used to avoid memory leak, in practice, whenever the cache size reaches that number, the GEM is going
to remove 25% of the key values, avoiding inflating memory.

``` ruby
Sidekiq::Statistic.configure do |config|
  config.max_timelist_length = 250_000
end
```

## Supported Sidekiq versions

Statistic support the following Sidekiq versions:

-   Sidekiq 6.
-   Sidekiq 5.
-   Sidekiq 4.
-   Sidekiq 3.5.

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
* `sidekiq:statistic` - redis hash with all statistic
  - `yyyy-mm-dd:WorkerName:passed` - count of passed jobs for Worker name on yyyy-mm-dd
  - `yyyy-mm-dd:WorkerName:failed` - count of failed jobs for Worker name on yyyy-mm-dd
  - `yyyy-mm-dd:WorkerName:last_job_status` - string with status (`passed` or `failed`) for last job
  - `yyyy-mm-dd:WorkerName:last_time` - date of last job performing
  - `yyyy-mm-dd:WorkerName:queue` - name of job queue (`default` by default)

For time information you should push the runtime value to `yyyy-mm-dd:WorkerName:timeslist` redis list.

## How it works
<details>
 <summary>Big image 'how it works'</summary>
    
 ![how-it-works](https://cloud.githubusercontent.com/assets/1147484/8802272/fc0a1302-2fc8-11e5-86a5-817409259338.png)

</details>

## Contributing
1. Fork it ( https://github.com/davydovanton/sidekiq-statistic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
