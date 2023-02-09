# Monaco 2.0 - Settings 2.0 Demo Project

This is a small sample project for Settings 2.0 configuration using monaco 2.0.0

It configures Web Application monitoring, including: 
* the general app config (Config v1)
* an auto-tag that's applied to the app (v2 Settings)
* rum enablement settings of the application (v2 Settings, in scope of App meId - set via reference)
* specific http errors to be ignored for AppDex (v2 Settings, in scope of App meId - set via reference)

And checks for the app availability, including:
* a (dummy) synthetic check (hitting google.com) (Environment v1)
* an SLO based on the synthetic (v2 Settings)

You need a test environment and the following environment variables to try this out:
* DEMO_ENV_URL
  * your test environment's url
* DEMO_ENV_TOKEN 
  * a token for the test environment with the scopes needed to edit configurations, synthetics and settings