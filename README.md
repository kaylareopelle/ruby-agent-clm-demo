# Ruby Agent Code Level Metrics Demo

This project uses the New Relic Ruby Agent to demonstrate the reporting of
code level metrics (CLM).

There is a Ruby on Rails 7 based web application contained in the `rails7`
directory. This application is designed to perform
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)
operations for fictitious future New Relic language agents.

By running the demo, the Ruby on Rails 7 application will be launched and
daemonized and a `tester` shell script will perform [curl](https://curl.se/)
commands that generate web traffic to exercise all traced Ruby methods.

## Important Source Files

For code level metrics, there are two important Ruby class files involved:

- `app/controllers/agents_controller.rb`: A fairly standard Rails 7 controller
  class, whose methods will automatically store CLM data in segments when
  called
- `lib/custom_helpers.rb`: A demonstration class file featuring 2 class (static)
  methods and 2 instance methods that will produce CLM data because of the
  transaction and method tracers that are applied to them

## Traced methods

The CRUD tests will generate 3 separate Rails controller action based New Relic
trace groups.

These are `Controller/agents/create`, `Controller/agents/show`, and
`Controller/agents/destroy`, which correspond to the `agents_controller.rb`
class file's `create`, `show`, and `destroy` methods. These groups should
each possess at least one span with CLM attributes.

Furthermore, the `Controller/agents/show` group contains additional in-process
spans named `OtherTransaction/Background/Custom::Helpers/custom_class_method`,
`OtherTransaction/Background/Custom::Helpers/custom_instance_method`, 
`Custom/CLMtesting/ClassMethod`, and `Custom/CLMtesting/InstanceMethod`.
These four additional spans contain CLM attributes related to the
`custom_helpers.rb` file.

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
