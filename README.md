# Dev-Knot Blog

Dev-Knot is a blog focused on Network Automation, DevOps and other general Dev Net content. This project manages the blog content and infrastructure deployment using Terraform, AWS, and GitHub Actions. Blog content is generated by Hugo.

Contact Forms are serverless AWS Lambda functions with React frontend hosted with Amplify.

## Prerequisites

- Install [Docker](https://www.docker.com/)
- Install [Hugo](https://gohugo.io/getting-started/installing/)

## Creating New Post

To create a new post, simply check out a new feature branch, build and run the docker image.

```bash
docker compose up -d
```

Now, cd into `dev-knot` folder and with `hugo` installed on your machine, run the following

```bash
hugo new content/posts/dev-ops/some-dev-ops-article.md
```

Example

```bash
> cd dev-knot
> hugo new content/posts/dev-ops/nautobot-cookie.md
Content "/Users/hugotinoco/Dropbox/DevKnot/dev-knot-blog/dev-knot/content/posts/dev-ops/nautobot-cookie.md" created
```

Edit away! Check in the feature branch and create a WIP pull request to get a preview of the blog content hosted on a temporary public URL. The link information will be posted into the PR comments by AWS Amplify. Once everything looks good, publish to `main`.

## Deployments - AWS Amplify

Builds are published from `develop` and the `main` branch upon successful merge. The builds are triggered in AWS Amplify via GitHub Webhooks. The `develop` branch will publish a preview version of the site with a public DNS entry that's subject to change. This can be found inside the AWS Console. Adding a custom domain to the development branch is also possible, but not complete yet. Rules can be created by branch as well. The `main` branch will publish to `www.dev-knot.com` and my old blog domain as well, `www.admin-save.com`.

### Docker Compose

This file contains the `terraform` image that controls deployments of the infrastructure used to host this blog. Additionally, an image is built and published to DockerHub as a standalone container of the blog before it's served to AWS Amplify.

## Terraform

Terraform is managed via a Docker container. The state backend is securely maintained on terraform cloud.
