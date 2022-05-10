# Ruby Agent Code Level Metrics Demo

This project uses the New Relic Ruby agent to demonstrate the reporting of
code level metrics (CLM).

There is a Ruby on Rails 7 based web application contained in the `rails7`
directory. This application is designed to perform
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)
operations for fictitious future New Relic language agents.

By running the demo, the Ruby on Rails 7 application will be launched and
daemonized and a `tester` shell script will perform [curl](https://curl.se/)
commands that generate web traffic to exercise all traced Ruby methods.

## Important Source Files

The following Rails class files define methods that will be invoked and produce
code level metrics.

- `app/controllers/agents_controller.rb`: A fairly standard Rails 7 controller
  class whose methods will automatically store CLM data in segments when
  called
- `app/controllers/admin/settings_controller.rb`: This controller exists to
  demonstrate directory nesting.
- `lib/custom_helpers.rb`: A demonstration class file featuring 2 class (static)
  methods and 2 instance methods that will produce CLM data because of the
  transaction and method tracers that are applied to them
- `lib/which_is_which.rb`: A class that bears both a `self.samename` (class
  method) and `samename` instance method.
- `app/jobs/notifier_job.rb`: An ActiveJob (background job processing) class
  featuring a `perform` method.

## Traced methods

### AgentsController

The `rails7/app/controllers/agents_controller.rb` file defines the
`AgentsController` class. This class has 3 instance methods that are exercised
by the demo, `create`, `destroy`, and `show`.

These 3 methods produce the following New Relic trace names:

- `Controller/agents/create`
- `Controller/agents/destroy`
- `Controller/agents/show`

### SettingsController

The `rails7/app/controllers/admin/settings_controller.rb` file defines the
`Admin::SettingsController` class. The file demonstrates a namespaced
controller class located in a nested directory beneath `controllers`. The
controller class defines a single instance method, `index`.

The `index` method produces the following New Relic trace name:

- `Controller/admin/settings/index`

### NotifierJob

The `rails7/app/jobs/notifier_job.rb` file defines the `NotifierJob` class.
This ActiveJob based class has the standard `perform` instance method that
serves as the single point of public entry into the job class.

CLM spans for this class will appear in New Relic as "non-web". The `perform`
method produces the following New Relic trace name:

- `OtherTransaction/ActiveJob::Async/NotifierJob/execute`

NOTE: The "Async" part of the trace name can be different between instances
of Rails applications. Starting with Ruby on Rails version 5, "Async" is the
default ActiveJob queue adapter, but it should not be used for production
traffic. In production it is likely that another background job adapter will be
in play. See the [complete list](https://edgeapi.rubyonrails.org/classes/ActiveJob/QueueAdapters.html) 
of adapters for details.

NOTE: The "execute" part of the trace name is hardcoded and will not change
between jobs.

### Custom::Helpers

The `rails7/lib/custom_helpers.rb` file defines the `Custom::Helpers` class.
This generic Ruby class does not contain any Rails or other non standard library
code. In a non demo app, this type of file could be stored anywhere the Rails
app has read access to.

The custom helpers file defines 2 class methods, `custom_class_method` and
`custom_class_method_too`, and 2 instance methods, `custom_instance_method`,
and `custom_instance_method_too`

Each of the 2 methods without "too" in the name invoke the 2 methods with "too"
in the name, so the metrics for the "too" methods will be nested by New Relic
accordingly.

The 4 methods produce the following New Relic trace names:

- `OtherTransaction/Background/Custom::Helpers/custom_class_method`
- `Custom/CLMtesting/ClassMethod` (for `custom_class_method_too`)
- `OtherTransaction/Background/Custom::Helpers/custom_instance_method`
- `Custom/CLMtesting/InstanceMethod` (for `custom_instance_method_too`)

### WhichIsWhich

The `rails7/lib/which_is_which.rb` file defines the `WhichIsWhich` class.
This class exists solely to demonstrate a Ruby class that has both a class
method and an instance method with the same name. The class possesses a
`self.samesame` class method an a `samesame` instance method.

Due to the way the New Relic Ruby agent currently traces Ruby methods, both
of these methods will use the same trace name. The `code.function` and
`code.lineno` CLM attributes will serve to differentiate the traces. The common
trace name is:

- `OtherTransaction/Background/WhichIsWhich/samename`

## Running the Demo With Docker

### Software Prerequisites

- [Docker](https://www.docker.com/get-started/)
- [GNU Make](https://www.gnu.org/software/make/) (optional if you're comfortable with `docker-compose`)

### Instructions

1. Clone this repository
1. Launch a terminal emulator and change to the directory of the repository clone
1. Set your New Relic license key via `export NEW_RELIC_LICENSE_KEY=the_key`
1. Optionally set a non-production New Relic host via `export NEW_RELIC_HOST=the_host`
1. Start Docker Compose via `make up` or `docker-compose up -d --build`
1. Inspect the Rails and New Relic agent logs that appear in the `logs` subdirectory
1. Leave the demo running for as long as you'd like
1. Stop Docker Compose via `make down` or `docker-compose down`
1. Optionally delete old logs and other temporary content via `make clean`
1. Optionally discard the Docker image via `make rmi`
1. If the Ruby agent was successful in posting data to New Relic, the data
   should soon be available in the web UI. The URL can be obtained via `make url`.

### Updating the Demo

1. Optionally run `make clean` and/or `git clean` to remove unwanted content
1. Update your local copy of the demo git clone
1. Make sure `rails7/Gemfile.lock` does not exist (if `make clean` was not used)
1. Remove any old demo Docker images with either `make rmi` or `docker`
1. Proceed to step 3 of the demo instructions

## Development and Debugging

- With [Ruby](https://www.ruby-lang.org/) version 2.7.0 or newer, the Rails 7
  app in the `rails7` subdirectory can be ran without Docker
- To run the Rails 7 app in console mode, change to the `rails7` subdirectory,
  run `bundle` and then run `bundle exec rails console`
- To test the Docker image with a Bash shell, override the entrypoint like so:
  `docker run --rm -it --entrypoint bash ruby-agent-clm-demo`
- The [SQLite](https://www.sqlite.org/) based database is seeded with content
  in the `rails7/db/seeds.rb` file
- The database schema is defined in `rails7/db/schema.rb`
- The `rails7/tester` script uses [Bash](https://www.gnu.org/software/bash/),
  [curl](https://curl.se/), and [jq](https://stedolan.github.io/jq/) and can
  be ran locally if you have all of those installed
- [puts](https://apidock.com/ruby/IO/puts) statements can be added to any of
  the `.rb` files inolved in the web application's CRUD operations to print
  output to the Rails log file
