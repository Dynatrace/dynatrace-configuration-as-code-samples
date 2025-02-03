### ArgoCD Sync Deployment event

| Property | Source | in Dashboard used | 
|---|---|---|
| event.id  |   |
| event.kind = "SDLC_EVENT" |   | x 
| event.version = "0.1.0" | |  x
| event.category = "task" | |  x
| event.type = "deployment" | |  x
| event.provider = "argocd" | |  x
| event.status | |  x
| duration | |  x
| start_time |   |
| end_time |   |
| timestamp |   |
| task.id |   |
| task.name |   |
| task.outcome | |  x
| deployment.service.uid | |  x
| deployment.service.name | |  x
| deployment.service.namespace | |  x
| deployment.service.revision | |  -
| deployment.source.revision | |  -
| deployment.source.repo.url | |  x
| deployment.project | |  -
| deployment.target.namespace | |  -
| deployment.target.server.url | |  -
| deployment.history | |  -
| deployment.images | |  -
| deployment.labels | |  -
| deployment.health.status | |  -
| deployment.sync.status |  | x
| deployment.reconciliation_time | |  -
| argocd.health.status | |  -
| argocd.sync.status | |  x
| argocd.reconciliation_time | |  -
| argocd.sync.previous_revision | |  -
| argocd.sync.outcome | |  x