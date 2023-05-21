---
title: "Batfish Cdk Ecs"
date: 2023-04-08T10:13:45-07:00
draft: true
---
# Deploying Batfish into ECS Cluster with Fargate using AWS CDK and TypeScript

## Introduction

In this blog post, we will discuss the deployment of Batfish Network Analysis using AWS CDK, Fargate, and Elastic Container Service (ECS) behind a Load Balancer. Batfish is an open-source network configuration analysis tool that enables network engineers to validate configurations, analyze policies, and ensure the correctness of their network deployments. We will dive into the challenges faced in setting up this deployment, the benefits of using container insights and logging, the use-case of having three replicas, and the implementation of session stickiness to maintain session persistence.

Batfish Network Analysis

Batfish Network Analysis is a powerful tool for network engineers to validate configurations, check compliance, and prevent configuration errors. With Batfish, engineers can analyze their network designs and policies in a vendor-neutral way, ensuring that the network behaves as expected.

Three Replicas Use-Case

In our deployment, we are using three replicas to provide high availability and load balancing. This allows us to distribute the load across multiple instances, ensuring that the system can handle increased traffic and remain operational in case of a single instance failure.

Challenges and Pain Points

One of the main challenges we encountered was setting up the health check for our containers. We had to use the all-in-one Batfish container instead of the slimmer batfish/batfish container because the latter requires specific headers to be passed to get a proper response, which is not possible with Fargate and ELB health checks. The all-in-one container, however, has more dependencies and may require and use resources that we don't need to host a Jupyter notebook and expose a port that we don't actually need.

Container Insights and Logging

Using container insights and logging, we can monitor and troubleshoot our ECS deployment effectively. Container insights provide us with valuable information about our containerized applications, such as CPU and memory utilization, network metrics, and more. This enables us to identify bottlenecks and optimize our deployment to provide the best possible performance. Logging is also essential for auditing and diagnosing issues within our deployment.

Implementing Session Stickiness

Stickiness is an essential feature when it comes to load balancing, as it helps maintain session persistence across multiple requests. In our Batfish Network Analysis deployment, we have implemented stickiness at both the group level and the task level to ensure session persistence. We used an Application Load Balancer (ALB) to distribute traffic among our three replicas.

At the group level, we created an Application Target Group and configured the stickiness settings with a stickinessCookieDuration value of 120 seconds. This configuration ensures that the load balancer directs client requests to the same target group for the specified duration, maintaining session persistence.

To implement task level stickiness, we added a listener to the Application Load Balancer and configured the stickinessDuration property with a value of 120 seconds. This configuration ensures that the requests are directed to the same container task within the target group, maintaining session continuity.

By implementing stickiness at both group and task levels, we have ensured that our Batfish Network Analysis deployment maintains session persistence, providing a consistent user experience and preventing potential issues due to session discontinuity. The use of an Application Load Balancer in our deployment allows for efficient traffic distribution among our replicas while maintaining the necessary session stickiness.

Conclusion

In this blog post, we discussed the deployment of Batfish Network Analysis using AWS CDK, ECS, and Fargate. We highlighted the challenges faced during the setup process, the benefits of using container insights and logging, the use-case of having three replicas, and the implementation of session stickiness for maintaining session persistence. By leveraging the power of AWS services and Batfish Network Analysis, network engineers can
