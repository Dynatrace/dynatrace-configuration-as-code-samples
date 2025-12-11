locals {
  http-input = [
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
nam-input = [
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
}