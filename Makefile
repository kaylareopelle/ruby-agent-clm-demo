all: up down logs bash rmi url clean
.PHONY : all

up:
		docker-compose up -d --build

down:
		docker-compose down

logs:
		docker-compose logs -f

bash:
	  docker run --rm -it --entrypoint bash ruby-agent-clm-demo

rmi:
	  docker rmi `docker images ruby-agent-clm-demo --quiet`

url:
	  grep 'INFO : Reporting to: https://' logs/newrelic_agent.log | awk '{print $$10}'

clean:
	  rm -rf logs/*
		rm -f rails7/Gemfile.lock
		rm -rf rails7/tmp/*
		mkdir -p rails7/tmp/pids
		touch rails7/tmp/.keep
		touch rails7/tmp/pids/.keep
		rm -rf rails7/log/*
		touch rails7/log/.keep
		rm -f rails7/db/*.sqlite3
