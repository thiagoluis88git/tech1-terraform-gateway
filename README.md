# Tech1 - Terraform repository files - API Gateway

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Description](#description)
- [How to use](#how-to-use)
    - [Dependencies](#dependencies)
- [Infrastructure resources](#infrastructure-resources)

## Description

The Tech Challenge 1 aims to do a solution for a Fast Food restaurant. This project is part of the entire solution. Here we have all the `Terraform` files to the **API Gateway infrastructure** to the `AWS` cloud. This **API Gateway** will be use to `authorize` the customer via a `Lambda Authorizer` using the `Cognito` as its customer credentials resource.
The **Lambda Authorizer** was created using `Python` language.

## How to use

To build the infractructure, just run the `Github Actions manual Workflow (Build Infrastructure)` on `Actions` tab. This will take some time (between 24 to 28 minutes). To destroy the infractructure, just run the `Github Actions manual Workflow (Destroy Infrastructure)` on `Actions` tab. This will take some time (between 8 to 14 minutes).

### Dependencies

To use this `Terraform deploy infrastructure`, we have some dependencies that we need to get from `Load Balancer` resource from the `Kubernetes Service` resource. These dependencies are:

- ARN Load Balancer
- DNS Load Balancer

This values must be set in `Variables` Github pipeline settings.

## Infrastructure resources

The API Gateway infrastructure will be created by this project. The core resources are:

- API Gateway
- Lamba Authorizer
