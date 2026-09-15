# Release procedure

This PR prepares packages; it does not rename the repository or publish them.

1. Merge the verified PR after approval. Keep historic Facturx tags and gems intact.
2. Rename the GitHub repository to `AdVitam/eu-einvoice` and update homepage/source/changelog URLs in the shared gemspec configuration and documentation.
3. Configure a pending Trusted Publisher for each of the six gem names using the exact new repository, `.github/workflows/release.yml`, and `release` environment.
4. Verify all required CI jobs on the release commit, including installed-artifact smoke tests, real Schematron and all five veraPDF profiles.
5. Build with `bundle exec rake build_all` and inspect package contents. Version all six packages together for this initial release.
6. Publish the tag `eu-einvoice-v1.0.0` only after approval. The prefix avoids collisions with retained historical `v1.0.0` tags.
7. Follow the release workflow to success and verify each package's version and installation from RubyGems. A partial publication is not rolled back by yanking other packages: inspect the failure and publish only missing artifacts deliberately.

The workflow has no branch-push publication trigger. It fails on tag/version mismatch or package verification failure. Runtime clients download no schemas, rules or code lists.

[RubyGems Trusted Publishing](https://guides.rubygems.org/trusted-publishing/)
