# Synthetic templates to reuse to create in bulk

## Network availability monitor (nam)

Iterates over a file with name, port, and ips
Takes inputs of type and location (but these can default to TCP in the [default location set in variables.tf](nam/variables.tf))

Array of json objects. Each object fields:
- name
- location (optional)
- frequency (optional - default 5m)
- requiredSynthetics - array of object
  - port (can be single value, range or comma separated)
  - ips - array of string

```
[
      {
        "name": "Testing",
        "requiredSynthetics": [
          {
            "port": "13013-13021",
            "ips": [
              "10.0.0.1"
            ]
          },
          {
            "port": "5001,5005",
            "ips": [
              "10.0.0.2",
              "10.0.0.3"
            ]
          },
          {
            "port": "5002",
            "ips": [
              "10.0.0.8"
            ]
          }
        ]
      }
]      
```


## HTTP Monitor

Array of json objects. Each object has fields:
- name
- location (optional)
- frequency (optional - default 5m)
- requiredSynthetics - array of object
  - url
  - certificateVerification - (optional - default false) integer, number of days
  - httpStatusesList - (optional - default >=400) false to not check or http status expression

`"httpStatusesList" : false` and `certificateVerification` not specified will cause an error as one condition must be set.

```
[
    {
        "name": "Test",
        "frequency": 60,
        "requiredSynthetics": [
            {
                "certificateVerification": "30",
                "httpStatusesList" : ">=500",
                "url": "https://www.dynatrace.com"
            },
            {
                "url": "https://www.google.com"
            }
        ]
    }
]
```