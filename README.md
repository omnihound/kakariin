# Kakariin

Kakariin (掛かり員 — the officials who run a kendo shiai-jō) is a Rails app for
running kendo tournaments: registration, bracket/pool generation, live
court scoring, and spectator views.

## Features

* **Tournaments & divisions** — individual or team divisions, each run as
  single elimination, round robin, or pools followed by an elimination
  bracket.
* **Registration** — competitors register into a division; team divisions
  build entries from team memberships and lineups.
* **Pools** — snake-seeded pool generation and standings (wins, then ippon
  difference, then seed).
* **Live scoring** — a court scorer view records ippons by technique
  (men/kote/dou/tsuki) and hansoku fouls (two hansoku against a competitor
  award their opponent an ippon); team matches are scored bout by bout
  (senpo/jiho/chuken/fukusho/taisho).
* **Court status board & spectator views** — current/next match per court
  and live bracket/pool updates, pushed over Action Cable so nothing needs
  a manual refresh.

## Getting started

Requirements: Ruby 3.4.8 (see [.ruby-version](.ruby-version)) and PostgreSQL.

```
bin/setup
```

This installs gems and prepares the database. Then start the dev server:

```
bin/dev
```

## Running tests

```
bin/rails test
```

## Deployment

The app is built as a Docker image for deployment with
[Kamal](https://kamal-deploy.org):

```
docker build -t kakariin .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name kakariin kakariin
```
