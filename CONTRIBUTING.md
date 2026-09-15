# Contributing to EuEinvoice

## Setup

```bash
mise install
bundle install
```

## Checks

```bash
ruby tooling/lint.rb
bundle exec rspec
bundle exec rake build_all
bundle exec ruby tooling/verify_packages.rb
```

Create changes on a feature branch and submit them through a pull request to the protected `master` branch.

Read `docs/architecture/README.md` before changing a package boundary. The central library must load independently of France, XML, PDF and Rails. Specs use an isolated Rails application and database. Run resource-heavy checks serially; preserve the tools' internal parallelism.
