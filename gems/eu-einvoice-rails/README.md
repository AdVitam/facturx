# eu-einvoice-rails

Official optional Rails integration: named clients, an explicit mapper generator, ActiveModel error presentation, notifications and Active Storage IO helpers. Require `eu_einvoice/rails`.

No model callbacks, database migrations or implicit persistence are installed. Rails 7.2, 8.0 and 8.1 are tested on compatible Ruby versions. JSON is constrained below 3 because these Rails releases use the positional-options JSON parsing API.

See the [Rails recipes](https://github.com/AdVitam/facturx/blob/master/DOCUMENTATION.md#rails-recipes).
