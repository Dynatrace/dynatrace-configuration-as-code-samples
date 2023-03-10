# Problem Notification - Sample Project

This is a sample project configuring problem notifications based on auto-tagging rules. 

This covers a use-case organizations see frequently: 

Development teams own Applications that are made up several services, databases, etc and run on different host or cloud infrastructures.

If something goes wrong with any of these components it is vital that Dynatrace problems find their way to the responsible team.

This sample shows the recommended best-practice to leverage auto-tagging to ensure everything a team owns gets a tag applied to it.
This tag is then used for an altering-profile, defining for what problems an alert should be created. 
This alerting-profile is then used to configure notifications. 

## Variations

The sample contains three sample auto-tagging rules: 
- a simple host group based one
- a Kubernetes namespace based one
- a "full" sample tagging resources in an AWS project, databases and services in a Kubernetes namespace

The sample contains both an Email and a Slack notification.

## Using the Sample

To use the sample for your own setup, make sure any variables in the Config YAML files are filled with your information. 

By default the host-group based auto-tagging and email notification is configured.

The auto-tagging samples are mutually exclusive configurations and commented out in the auto-tag/config.yaml.
To use a different sample un-comment it (remove leading #) and comment out the other samples.

The slack notification is skipped using monaco and can be used by simply setting the value of skip to false.

The sample manifest.yaml requires two envrionment variables to be set: 
* DEMO_ENV_URL (your Dynatrace URL)
* DEMO_ENV_TOKEN (your Dynatrace API Token with at least 'settings.read','settings.write', 'Data Export' permissions)

## Cleanup

You can use the supplied delete.yaml to remove all configurations created by this sample.