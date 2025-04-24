# APL Clients

Factory to build and publish openapi clients used in the [linode/apl-tasks](https://github.com/linode/apl-tasks) repo. Part of APL - Application Platform for LKE (Linode Kubernetes Engine).

## Generate openapi clients for vendors

To build and publish new vendor clients, just download and inspect their openapi spec if it is suitable, then integrate it.

Steps:

- put the api spec in `src/vendors/openapi/$vendor/*.json`
- add a line in `bin/generate-all.sh` to include your package
- make sure the credentials used in `.github/workflows/default.yaml` have rights to publish that package

To create one the very first time to see if it all works:

```bash
bin/generate-client.sh $vendor $version
```

This will generate `vendors/client/$vendor/$type`, with `$version` being the version number according to the file stored.

The above script uses openapi-generator tool for typescript. Read about more typescript options at: <https://openapi-generator.tech/docs/generators/typescript-node>

## Publish as npm package

In order for others to use the generated client package, please commit the code and the github workflow will run tests and publish.

### NPM: authentication and publication

To control npm access, like wiring up a private repo please follow these instructions:

- [Authenticating with a personal access token](https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-npm-for-use-with-github-packages#authenticating-with-a-personal-access-token)
- [Creating a personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)
- [Configuring npm for use with github packages](https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-npm-for-use-with-github-packages)
- [Publishing a package using a local npmrc file](https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-npm-for-use-with-github-packages#publishing-a-package-using-a-local-npmrc-file)

# Troubleshooting

## Npm publish

```
npm ERR! Invalid version: "2.0"
```

Solution: Update version in api spec to make it conform to semver. E.g.: change version to `2.0.0` and then generate client once again.
