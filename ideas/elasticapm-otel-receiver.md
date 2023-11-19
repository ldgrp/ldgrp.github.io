---
title: An OpenTelemetry receiver for Elastic APM
last-edited: 2023-08-07
date: 2023-08-06
status: done
meta-img: https://github.com/ldgrp/elasticapmreceiver/raw/main/docs/jaeger_sample.png
---

An experimental OpenTelemetry receiver can be found at [https://github.com/ldgrp/elasticapmreceiver][repo].

[Elastic APM][elastic-apm] is an enterprise observability solution that supports
tracing, metrics, and logs. Typically, users can configure [Elastic APM
Agents][elastic-apm-agents] to instrument, collect, and send telemetry data to [Elastic APM Server][elastic-apm-server].

[OpenTelemetry][opentelemetry] is a vendor-neutral collection of APIs, SDKs, and tools for creating, collecting, 
and managing telemetry data. Elastic APM Server is capable of
receiving data both from native Elastic APM Agents, and anything that
sends data in [OpenTelemetry Protocol][otlp] (OTLP) format. 

However, there is no way for existing applications instrumented with
Elastic APM Agents to send data to _other_ backends. This makes
experimenting and evaluating other observability solutions difficult.

An OpenTelemetry receiver can be used to mimic the [intake API][intake] of 
Elastic APM Server. This allows existing applications to send data
to an OpenTelemetry Collector, which will transform the data into
OpenTelemetry Span data, and send it to any backend.

[elastic-apm-agents]:https://www.elastic.co/guide/en/apm/agent/index.html
[elastic-apm-server]:https://github.com/elastic/apm-server
[elastic-apm]: https://www.elastic.co/observability/application-performance-monitoring
[intake]:https://www.elastic.co/guide/en/apm/guide/current/api-events.html
[opentelemetry]:https://opentelemetry.io/docs/what-is-opentelemetry/
[otlp]:https://opentelemetry.io/docs/specs/otel/protocol/
[repo]:https://github.com/ldgrp/elasticapmreceiver