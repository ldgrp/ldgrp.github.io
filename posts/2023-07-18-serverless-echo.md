---
title: Building a websocket echo server in 33 lines of code
date: 2023-07-18
last-edited: 2023-07-18
---

The code below shows how to build a simple websocket echo server with AWS Lambda and API Gateway, with all the infrastructure management handled by Pulumi.
A GitHub repository with the full code is available [here][repo].

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

const echoHandler = new aws.lambda.CallbackFunction("echoHandler", {
  callback: async (event: any) => ({ statusCode: 200, body: event.body })
});

const api = new aws.apigatewayv2.Api("api", { protocolType: "WEBSOCKET" });

const integration = new aws.apigatewayv2.Integration("defaultIntegration", {
  apiId: api.id,
  integrationType: "AWS_PROXY",
  integrationUri: echoHandler.invokeArn,
});

const defaultRoute = new aws.apigatewayv2.Route("defaultRoute", {
  apiId: api.id,
  routeKey: "$default",
  target: pulumi.interpolate`integrations/${integration.id}`,
});

const deployment = new aws.apigatewayv2.Deployment(
  "deployment",
  { apiId: api.id },
  { dependsOn: [defaultRoute]}
);

const stage = new aws.apigatewayv2.Stage("stage", {
  apiId: api.id,
  name: "dev",
  deploymentId: deployment.id,
});

export const url = pulumi.interpolate`${api.apiEndpoint}/${stage.name}`;
```

1. `echoHandler` defines a Lambda function that returns the body of the request (the echo).
2. `api` creates a new API Gateway configured for websockets.
3. `integration` associates the Lambda function with the API Gateway. It also configures the integration type to be `AWS_PROXY`, which means that the Lambda function will receive the entire request object.
4. `defaultRoute` handles incoming requests that don't match any other route. In this case, it matches all requests.
5. `deployment` creates a new deployment of the API Gateway. This is required before we can create a stage.
6. `stage` represents a state of the API Gateway. In this case, it's just the `dev` stage but we could create multiple stages for different environments (e.g. `prod`).
7. Finally, `url` is the URL of the API gateway combined with the stage name. This is the URL that clients can connect to.

[repo]: https://github.com/ldgrp/serverless-ws-echo