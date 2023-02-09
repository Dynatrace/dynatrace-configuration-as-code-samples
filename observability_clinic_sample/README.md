# Monaco 2.0 - Observability Clinic Demo

This folder contains sample projects used in the Demo section of the [Observability Clinic on Monaco 2.0](https://dt-url.net/monaco-observability-clinic).

You find the following things in here: 

```
/commands
    --> shell scrips that simplify the monaco calls used in the demo
/existing_v1_config
    --> a monaco v1 project
/expected_v2_config
    --> the expected outcome of converting the v1 project using monaco 2.0.0 (just for reference)
/settings-demo
    --> a monaco v2 project configuring Settings in addition to Configs
```

In each of the sample folders you will find a `README.md` file with more information about the sample.

# Prerequisites

## Monaco Exectuables

You will need `monaco-1.8.9` and `monaco-2.0.0` executables in the root folder of the repo for the commands to work.

Download the respective versions from the [release page](https://github.com/Dynatrace/dynatrace-configuration-as-code/releases) and make sure you rename the executables as mentioned above, for the command scripts to work.

## Dynatrace Environment

You will need a Dynatrace environment and put it's URL and TOKEN into a `demo.env` file that looks like the [`sample.env`](./sample.env) file provided in the repo.
The token needs permission to Read/Create: Synthetic Monitors, Configurations and Settings.

# Demo Steps / Commands

## Deploying v1

```shell
./commands/deploy-v1.sh
```

Starting from an empty Dynatrace environment deploy v1 - this is pretty boring if you know monaco and Dynatrace.

Then you will find a Web Application, a Synthetic Monitor, an Auto-Tag and an SLO in your environment.

## Converting v1 -> v2

```shell
./commands/convert-v1.sh
```

This converts the v1 configuration into v2 format.

Afterwards check out the `converted-v2-config` folder!

## Deploying v2

```shell
./commands/deploy-v2-converted.sh
```

This will update all the configurations previously created using monaco v1.

## Cleanup

```shell
./commands/cleanup.sh
```

As the settings demo contains some Settings overlapping Configurations created by the previous samples, we need to remove what's deployed so far.

> In a real case of migrating e.g. an Auto Tag from it's configuration API to the Settings schema, one could instead download the Settings object and then just remove the old auto-tag API configuration as code files. For the sake of the demo, we just reset the envrionment.
 

## Deploying Settings

Take a look at the settings-demo project and its [README.md](./settings-demo/README.md).

The project contains several things only possible via settings - like configuring Real User Monitoring settings for our app. 

```shell
./commands/deploy-v2-settings.sh
```

## Changing Settings

Now take a look at the Application's settings (Edit) in the Dynatrace UI.
It will have real user monitoring enabled for 100% of traffic and session replay for 80%. 

As we don't need any session replay for our fake application, modify the [applicationConfig.yaml](./settings-demo/project/app/applicationConfig.yaml) and set `sessionReplayEnabled` to false on line 34.

```shell
./commands/deploy-v2-settings.sh
```

After re-deploying the application settings are updated and session replay is disabled.

# Cleanup

```shell
./commands/cleanup.sh
```

Remove all demo configs from your environment.