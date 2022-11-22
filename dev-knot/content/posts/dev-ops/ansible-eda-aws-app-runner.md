---
title: "Ansible EDA - AWS App Runner"
weight: 1
date: 2022-11-22T00:02:18Z
draft: false
featuredImage: "/images/2022-11/ansible-aws.png"
featuredImagePreview: "/images/2022-11/ansible-aws.png"
categories:
  - Ansible
  - DevOps
  - Cloud
tags:
  - Ansible
  - DevOps
  - Cloud
  - ansible-eda
hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
fontawesome: true
linkToMarkdown: true
rssFullText: false
toc:
  enable: true
  auto: false
code:
  copy: true
  maxShownLines: 50
---

# Ansible Event Driven Automation with AWS App Runner

Welcome everyone! I've been hearing a lot of buzz around Ansible EDA since this year's AnsibleFest. It's peaked my interest, as it's a very different solution that's being provided by Ansible to what we're all familiar with. Additionally, the last few weeks I have been wanting to use AWS App Runner. It's a relatively new feature from the AWS team which abstracts the complexity of deploying containers with Fargate and ECS. Well, what a time to be alive! I have decided to see if I can make the two newish technologies play nice with each other. This blog post will go over how to publish a container to ECR through a Github Actions Pipeline. This container will be a new service hosted through AWS App Runner. Lets get started!

> Do you want to just look at the code? Checkout my [aws-app-runner-ansible-eda](https://github.com/h4ndzdatm0ld/aws-app-runner-ansible-eda) repository on Github

## Ansible Event Driven Automation

The new [EDA](https://www.ansible.com/use-cases/event-driven-automation) feature by the RedHat Ansible team is not an entirely new concept, but it could be a powerful way to adopt this approach with tools that are already at your disposal or potentially in production within your organization today.

> Blog Alert!: To get more details on Ansible EDA - checkout this official [blogpost](https://www.ansible.com/blog/introducing-event-driven-ansible) by RedHat

### Building the Ansible EDA Container

Ansible provides two ways to configure the EDA listening server. There is a [collection](https://github.com/ansible/event-driven-ansible) which provides a playbook that deploys the configuration. Alternatively, there is a python library, [ansible-rulebook](https://github.com/ansible/event-driven-ansible) that you can install into your virtual environment which produces the same output. I chose to go the python library route to package a container image. The collection is still required, but running the installation playbook can be omitted if the python library is used.

I use a multi-stage docker build to create the final image. There was one tricky thing that I found a clever way to bring into my final image, which was Java. If you want to reference the latest Dockerfile, click [here](https://github.com/h4ndzdatm0ld/aws-app-runner-ansible-eda/blob/develop/Dockerfile). As a final result, here is the what last stage of the build looks like to attempt to make it as small as possible. To be honest, I'm not happy with the size of the image. However, one thing I've learned is that an image size is correct if it works for you. I try not to get hung up on it, but it's truly an art to make it as tiny as possible and always a fun challenge.

```bash
FROM python:3.9-slim AS cli

WORKDIR /usr/src/app

COPY --from=base /usr/src/app /usr/src/app
COPY --from=base /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=base /usr/local/bin /usr/local/bin
COPY --from=ansible /usr/share /usr/share
COPY --from=openjdk:20-slim /usr/local/openjdk-20 /usr/local/openjdk-20

ENV JAVA_HOME /usr/local/openjdk-20

EXPOSE 5000/tcp
EXPOSE 5000/udp

ENTRYPOINT ["ansible-rulebook"]
```

As you can see, I grab the `usr/local/openjdk-20` from the `openjdk:20-slim` image and copy it into my final image. You must also set the `ENV` of `JAVA_HOME` for proper execution. This hung me up for a little while, but the failing logs gave away good detail to get this running locally. There was another requirement that had to be put into my `base` image, which was `libssh-dev` and `python3-apt`. These packages are missing from the `slim` containers, so I had to install them early into my foundational image during the multi-stage build process. Nothing else was out of the ordinary for my normal build process to execute ansible-playbooks, which was kind of a nice win-win for me.

### Publishing Image to ECR

We'll go into more detail into how to deploy an Amazon Elastic Container Registry later, which is a requirement if you want to use AWS App Runner. You can either use a public ECR or private ECR. In my case, i'm going to use a private ECR. Right now, lets focus on how to push images to the registry with Github Actions.

The below snippet is part of the action that will push images to AWS ECR. I had never used ECR before and I found this video very helpful to automate the publishing of images - [Github Actions to AWS ECR](https://www.youtube.com/watch?v=yv8-Si5AB3U). One key part to this is to build an IAM User and Group with full access to ECR. In my case, I built a group with `AmazonEC2ContainerRegistryFullAccess` and added a user to it. I used this new user's credentials to interact with AWS API. The credentials are stored in my [Github Repo Action Secrets](https://docs.github.com/en/rest/actions/secrets).

```yaml
build:
  name: "Build Image & Publish to ECR"
  if: "github.ref == 'refs/heads/main'"
  needs:
    - "lint"
  runs-on: "ubuntu-latest"
  steps:
    - name: "Checkout repo"
      uses: "actions/checkout@v3"

    - name: "Configure AWS credentials"
      uses: "aws-actions/configure-aws-credentials@v1"
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: "us-west-2"

    - name: "Login to Amazon ECR Public"
      id: "login-ecr-public"
      uses: "aws-actions/amazon-ecr-login@v1"

    - name: "Build, tag, and push docker image to Amazon ECR"
      env:
        REGISTRY: ${{ steps.login-ecr-public.outputs.registry }}
        REPOSITORY: "ansible-eda"
        IMAGE_TAG: "latest"
      run: |
        export COMMIT_IMAGE=$REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker compose build cli
        docker push $COMMIT_IMAGE
```

A simple way to package the image using docker compose is to set a variable and override it during the build. Above, I export `COMMIT_IMAGE` and docker-compose uses this value to tag the latest image. I then use that same variable to push the docker image to ECR. Here is what my docker compose service looks like, particularly where the `image` value is set. This variable of `COMMIT_IMAGE` has been set with a default value of `h4ndzdatm0ld/ansible-eda:latest`, but if it were to find that variable, it would prefer it.

```yaml
image: "${COMMIT_IMAGE:-h4ndatm0ld/ansible-eda:latest}"
```

Finally, notice that this action will only be triggered when it's merged into `main` and once the `lint` job has been successfully completed. The lint job is just a collection of linting rules that must be met amongst all the code packaged into the image. This means all my playbooks, rule books, etc. must be up to standards before being able to be considered for a release and push. AWS App runner allows you to re deploy a service if a new container image is detected in the registry, automatically. This is a very powerful feature, but it should be carefully considered as a bad image could be automatically pushed out to production.

### Image Contents

I organized the directory structure to subdirectories per action. Since we are now dealing with a new concept of `rulebooks` I created a directory to match this and the same for `playbooks`.

```bash
├── playbooks
│   └── pb.dev-knot.yml
├── rulebooks
│   └── rb-webhook-5000.yml
```

The `ENTRYPOINT` into the container is `ansible-rulebook` which requires a few arguments. In my case, i'm orchestrating the containers with Docker Compose so my entry point is set and my service has the following set for the `command` option

```yaml
command: "--rulebook rulebooks/rb-webhook-5000.yml -i inventories/dev/hosts.yml --verbose"
```

This tells the `ansible-rulebook` to execute the `rb-webhook-5000.yml` rulebook in the `rulebook` directory and to use the `inventories/dev/hosts/yml` inventory. Additionally, we set the `--verbose` flag to get some nice output that will be visible within AWS's `cloudwatch` for our App Runner service.

The rulebook is just a copy pasta from the example out of the Ansible EDA Github repo

```yaml
---
- name: "LISTEN FOR WEBHOOK EVENTS"
  hosts: "all"
  sources:
    - ansible.eda.webhook:
        host: "0.0.0.0"
        port: 5000

  rules:
    - name: "SAY HELLO!"
      condition: "event.payload.message == 'Ansible is super cool'"
      action:
        run_playbook:
          name: "playbooks/pb.dev-knot.yml"
```

However, the playbook being executed is under the `playbooks` directory with the correct name. The listening port is kept at `5000` and the `condition` is also kept to match the message of `Ansible is super cool`. If this condition is met, the below playbook will be executed. A simple debug output message will be displayed.

```yaml
---
- name: "DEV-KNOT - ANSIBLE EDA"
  hosts: "all"
  connection: "local"
  gather_facts: false
  tasks:
    - name: "ANSIBLE EVENT DRIVEN AUTOMATION EXAMPLE"
      ansible.builtin.debug:
        msg: "I AM A TRIGGERED ACTION! I COULD BE DOING A WHOLE LOT!"
```

Lets talk about the infrastructure next!

## Terraforming AWS Infra

For my use-case I leveraged Terraform Cloud which has a `dev-knot` organization broken into workspaces per repository. This allows me to have [variable-sets](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/variable-sets) within my organization, which comes in handy with something like my AWS Credentials. The AWS provider settings are all ingested as environment variables, which is why you see an empty `{}`.

```bash
terraform {
  cloud {
    organization = "dev-knot"
    workspaces {
      name = "aws-app-runner-ansible-eda"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {}
```

### ECR

Well, we know that we will be using a container image and it must be stored within Amazon's ECR. This was the easiest part of this entire demo. Notice this is just [ECR](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) module not the `public` ECR module. There is a difference.

```bash
resource "aws_ecr_repository" "ansible_eda" {
  name                 = "ansible-eda"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

The scan on push is quite interesting, as you get to view vulnerabilities very quickly from the AWS Console.

Yikes!

![Code Scan](/images/2022-11/code-scan.png "Code Scan")

### App Runner

A few highlights on the [App Runner Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service), the deployment requires the `access_role_arn` to point to a capable IAM Role. Review the repository code for the latest [terraform manifest](https://github.com/h4ndzdatm0ld/aws-app-runner-ansible-eda/blob/develop/infra/iam.tf) to create the necessary IAM role. In the end, it's a role requiring access to ECR, which is accomplished by `AWSAppRunnerServicePolicyForECRAccess`.

```bash
resource "aws_apprunner_service" "app_ansible_eda" {
  service_name = "aws-app-runner-ansible-eda"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner-service-role.arn
    }
```

The app runner service also needs to be configured to be deployed with an `image_repository`, hence the ECR. We specify a port (default of 5000 for Ansible EDA) and a start command. The start command is what the container will need to properly execute the rulebook when it's ready to start. The rest of the options are self explanatory, which just point to the image name and the type. However, there is an important piece below which is the `auto_deployments_enabled`. If a new image is detected in the ECR repository, the service will redploy with the `latest` image. So cool! This allows developers to follow a git flow model and the production grade image is published to the container registry and automatically published. This is all done through github actions (in our case). A true infra as code approach. Absolutely love it. Finally, the health check is just a helpful bit as we want to ensure port 5000 is accessible.

```bash
    image_repository {
      image_configuration {
        port          = "5000"
        start_command = "--rulebook rulebooks/rb-webhook-5000.yml -i inventories/dev/hosts.yml --verbose"
      }
      image_identifier      = "${aws_ecr_repository.ansible_eda.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }
  health_check_configuration {
    healthy_threshold   = 1
    interval            = 10
    path                = "/"
    protocol            = "TCP"
    timeout             = 5
    unhealthy_threshold = 5
  }
  tags = {
    Name = "ansible-eda"
  }
}
```

## The Final Product!

Once everything is deployed into AWS via terraform and you've successfully published a working container, the service should deploy and you will see some nice logs through CloudWatch. Below is a snippet of the application logs from the container deployment.

![CloudWatch](/images/2022-11/cloudwatch.png)

Health checks are performed against port 5000 and you can see the automatic deployments from ECR are configured. Now, what about the actual application logs from our `--verbose` output. AWS provides us with `deployment logs` and `application logs`

### Testing the Webhoook

AWS App runner provides you with a custom FQDN to the service. The service itself forwards all traffic to the PORT specified in the service, which in our case is 5000. In the Ansible EDA documentation, you can see the webhook pointing to `localhost:5000/endpoint` but our service is hosted in AWS infra and automatically handles the port. So we need to just grab the FQDN and send a webhook to `https://www.my-fqdn-app-runner-service.com/endpoint`. Lets see an example of how I triggered the rulebook!

> curl -H 'Content-Type: application/json' -d "{\"message\": \"Ansible is super cool\"}" https://qmbzhax2ub.us-west-2.awsapprunner.com/endpoint --verbose

> NOTE: The port definition is omitted, this is very important otherwise this will not work.

Lets see the results!

There are quite a bit of logging options enabled by default, so the differnces are outlined below between Deployment and Application logs. We'll look at `application logs` to view the results of the webook.

![App Logs](/images/2022-11/app-logs.png)

The output below shows the container executing the rulebook and the listening service begins. Then, a webhook is sent to the public URL and the EDA service kicks off the playbook which runs the debug output.

![App Logs](/images/2022-11/triggered-webhook.png)

That's it! you can see that the webhook was triggered at the correct endpoint and the rulebook kicked off the playbook.

## Summary

Orchestrating the entire lifecycle of this simple demo project was quite interesting as both of these two technologies were new to me. The deployment via terraform was fun to figure out as I didn't understand the IAM role association to access ECR until I had to dig deep into why the Terraform Module gave me a not so helpful error. Additionally, ensuring that you omit the port number on the public FQDN was a good gotcha, as well when sending the webhook to trigger the rulebook/playbook. I hope you enjoyed this post!

- Hugo

```

```
