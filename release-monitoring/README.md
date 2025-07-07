# Release Monitoring

This package provides a preconfigured Dynatrace dashboard for monitoring and analyzing software releases across your environments. The dashboards deliver both high-level overviews and detailed insights into release activities, validation results, and associated risks such as detected vulnerabilities.

## Features

- **Comprehensive Release Overview:** Visualize all releases across environments at a glance.
- **Detailed Filtering:** Drill down to specific releases or environments for more granular analysis.
- **Risk & Validation Tracking:** Quickly identify validation outcomes and potential risks (e.g., vulnerabilities) associated with each release.
- **Ready-to-Use Dashboards:** Get started quickly with pre-built dashboards and example configurations.

## Prerequisites

To enable accurate release detection and ensure the dashboards work as intended:

- Review and implement Dynatrace [version detection strategies](https://docs.dynatrace.com/docs/deliver/release-monitoring/version-detection-strategies).
- Ensure all required prerequisites listed in the Dynatrace documentation are met.

## Dashboard Previews

| Overview | Filtered |
|----------|----------|
| ![Overview Dashboard](images/release_monitoring_overview.png) | ![Filtered Dashboard](images/release_monitoring_filtered.png) |

## Getting Started

1. **Clone or Download** this repository.
2. **Import the Dashboard:** Follow the instructions in the dashboard JSON or documentation to import it into your Dynatrace environment.
3. **Configure Version Detection:** Set up version detection according to the [official documentation](https://docs.dynatrace.com/docs/deliver/release-monitoring/version-detection-strategies).
4. **Customize as Needed:** Adjust the dashboards or detection rules to fit your organization’s release processes.

## Documentation

- [Dynatrace Release Monitoring Docs](https://docs.dynatrace.com/docs/deliver/release-monitoring)

## Feedback & Contributions

Contributions and feedback are welcome! Please open issues or pull requests in this repository or reach out via Dynatrace Community.