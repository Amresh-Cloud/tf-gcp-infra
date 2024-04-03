# tf-gcp-infra

- API Enabled

- Compute Engine API

- Added Yml

- Added Firewals

- Added SSH Blocking,

-  Enabled HTTP

-  Added VM Instance


## Load Balancing

- External Application Load Balancer is configured to support HTTPS protocol.
- SSL certificates are set up using Google-managed SSL certificates.
- APIs are accessible via HTTPS protocol on port 443.

## Autoscaling

- Regional compute instance template matching the current VM deployment is created.
- Compute health check is configured to use the `/healthz` endpoint in the web application.
- Compute autoscaler resource is set up to scale up when CPU usage exceeds 5%.
- Regional compute instance group manager is created incorporating the above resources.


