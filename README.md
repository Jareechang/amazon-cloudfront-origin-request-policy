# Amazon cloudfront: Create a distribution + Lambda (Tutorial) 

The finished repository of the tutorial [Amazon Cloudfront: Origin request policy (tutorial)](https://www.jerrychang.ca/writing/amazon-cloudfront-origin-request-policy).

# Goal

Learn how to add origin request policy to your Cloudfront distribution using terraform

# Getting started

1. Build the lambda function (under `functions/*`)

```sh
pnpm run generate-assets --filter "@functions/*"
```

2. Apply the infrastructure

```sh
export AWS_ACCESS_KEY_ID=<your-key>
export AWS_SECRET_ACCESS_KEY=<your-secret>
export AWS_DEFAULT_REGION=us-east-1

terraform init
terraform plan
terraform apply -auto-approve
```

# The Architecture

<img src="https://www.jerrychang.ca/images/cloudfront-tutorial-architecture.png" />

# Other Resources

- [Amazon Cloudfront: An overview of policies](https://www.jerrychang.ca/writing/amazon-cloudfront-an-overview-of-policies)

- [HTTP caching: The 6 core concepts](https://www.jerrychang.ca/writing/http-caching-the-6-core-concepts)

- [HTTP Caching: In-Practice](https://www.jerrychang.ca/writing/http-caching-in-practice)

- [Amazon Cloudfront: Caching deep dive](https://www.jerrychang.ca/writing/amazon-cloudfront-caching-deep-dive)
