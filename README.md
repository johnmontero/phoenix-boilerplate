# Phoenix 1.5.1 Bootsrap Project

An umbrella template for phoenix projects following good practices with separation of logic, data and interfaces.

## What is includes?

- Elixir 1.92
- Phoenix Framework 1.5.1
- Releases with Docker
- Docker compose for development
- Dev environment with credo and ssl

## Install Requirements

All the services for the project run inside docker containers, for that we need install Docker and Docker Compose.

Download Docker for Mac Os
```shell
https://download.docker.com/mac/stable/Docker.dmg
```

Install Docker for Linux
```shell
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $(whoami)
curl -L "https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Install cmake on macOS
```shell
brew install cmake
```

Install cmake on Linux
```shell
apt install cmake
```

## Bootstrap project

Bootstraping the project is really easy, you only need set you env variables and run a few commands for install dependencies.

Copy the .env.example file to .env
```shell
cp .env.example .env
```

Install dependencies
```bash
make deps.get
make app=data ecto.create
make app=frontend gen.cert
make app=frontend npm.install
```

Run services and open in browser *http://localhost:8080*
```shellf
make phx.run
```

If you want a pre commit hook for tests and coverage
```shell
cp script/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Customize the project

Since this is an umbrella project you can easily add more apps or delete the templates apps.

Adding more apps manually
```bash
make phx.shell
cd apps
mix new my_app --sup
```

Adding a phoenix app without eco
```bash
make phx.shell
cd apps
mix phx.new my_app --no-ecto
```

Adding a phoenix app only for rest services
```bash
make phx.shell
cd apps
mix phx.new my_app --no-ecto --no-webpack --no-html
```

When a new app is added, its necessary modify the *docker-compose.yml*, *Dockerfile*and *src/rel/config.ex* to add the volume for assets, ports and apps in release setup.

In *docker-compose.yml* add ports info for each app
```bash
version: '3.7'
services:
  phx:
    ports:
      - ${FRONTEND_HTTP_PORT}:${FRONTEND_HTTP_PORT}
      - ${FRONTEND_HTTPS_PORT}:${FRONTEND_HTTPS_PORT}
      - ${OTHER_APP_HTTP_PORT}:${OTHER_APP_HTTP_PORT}
      - ${OTHER_APP_HTTPS_PORT}:${OTHER_APP_HTTPS_PORT}
```

In *docker-compose.yml* add volumes for each app with assets
```bash
version: '3.7'

volumes:
  deps:
  builds:
  node_frontend:
  node_other_app:

services:
  phx:
    volumes:
      - ./src:/app/src
      - ./scripts:/scripts
      - deps:/app/src/deps
      - builds:/app/src/_build
      - node_frontend:/app/src/apps/frontend/assets/node_modules
      - node_other_app:/app/src/apps/other_app/assets/node_modules
```

In *src/rel/config.ex* add each app in to release   setup
```bash
release :phx do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
    frontend: :permanent,
	other_app: :permanent
  ]
```

In *Dockerfile* add each app for build assets distribution
```bash
WORKDIR /app/src/app/frontend/assets
RUN npm install \
      && npx webpack --mode production
WORKDIR /app/src/app/other_app/assets
RUN npm install \
      && npx webpack --mode production
```

Each app use four types for settings files:
- config.ex: General and static settings
- dev.ex: Development and dynamic settings using `System.get_env`
- test.ex: Test settings
- prod.ex: Production and dynamic settings using `{:system, "VARNAME"}`_ 
Don’t forget add config tuple on each applications mix.exs
```bash
      {:config_tuples, "~> 0.4.1"},
```

## Make a release for production

For production release we are using Docker, the Dockerfile is able to create the release and an images with everything you need for running your production app.

Build a new docker images
```
docker build -t <NAME:TAG> .
```

Submit to a repository
```
docker push <NAME:TAG>
```

## Commands

- make phx.run: Start applications services and an interactive phx shell
- make phx.shell: Open a shell in web service container
- make psql.shell: Open a shell in postgres service container
- make deps.get: Get and compile dependencies
- make test: Run tests
- make test.shell: Open a shell for testing
- make test.credo: Run credo
- make test.cover: Run coverage reports
- make app=app-name gen.certs: Create self signed certs
- make app=app-name npm.install: Run npm install
- make app=app-name ecto.create: Create databases
- make app=app-name ecto.migrate: Run migrations
- make app=app-name ecto.reset: Delete database and recreate all
- make app=app-name ecto.gen.migration name=migration-name

## Deploy Gigalixir

##  Console Remote
gigalixir ps:remote_console -o "-i ~/.ssh/identity/devops@gigalixir/id_rsa"

## Reset the Database
Ecto.Migrator.run(Data.CoreRepo, Application.app_dir(:data, "priv/core_repo/migrations"), :down, [all: true])

##  Run all migration
Ecto.Migrator.run(Data.CoreRepo, Application.app_dir(:data, "priv/core_repo/migrations"), :up, [all: true])

# Admin user
seed_script = Path.join(["#{:code.priv_dir(:data)}", "core_repo/seeds", "user_admin.exs"])
Code.eval_file(seed_script)

# Type Permission
seed_script = Path.join(["#{:code.priv_dir(:data)}", "core_repo/seeds", "type_persmission.exs"])
Code.eval_file(seed_script)

# File Types
seed_script = Path.join(["#{:code.priv_dir(:data)}", "core_repo/seeds", "file_types.exs"])
Code.eval_file(seed_script)

# Type Roles
seed_script = Path.join(["#{:code.priv_dir(:data)}", "core_repo/seeds", "type_role.exs"])
Code.eval_file(seed_script)

# Roles
seed_script = Path.join(["#{:code.priv_dir(:data)}", "core_repo/seeds", "roles.exs"])
Code.eval_file(seed_script)

# Type Documents
seed_script = Path.join(["#{:code.priv_dir(:data)}", "core_repo/seeds", "type_documents.exs"])
Code.eval_file(seed_script)


git -c http.extraheader="GIGALIXIR-HOT: true" push gigalixir master

git -c http.extraheader="GIGALIXIR-CLEAN: true" push gigalixir master