# Monaco 1.x - Demo Project

This is a small sample project for configuration using monaco 1.x

It configures Web Application monitoring, including: 
* the general app config (Config v1)
* an auto-tag that's applied to the app (Config v1)

And checks for the app availability, including:
* a (dummy) synthetic check (hitting google.com) (Environment v1)
* an SLO based on the synthetic (Config v1)

You need a test environment and the following environment variables to try this out:
* DEMO_ENV_URL
  * your test environment's url
* DEMO_ENV_TOKEN 
  * a token for the test environment with the scopes needed to edit configurations, synthetics and settings