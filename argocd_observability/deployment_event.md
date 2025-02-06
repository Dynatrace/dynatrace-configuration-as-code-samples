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
| start_time | |  x
| end_time | |  x
| timestamp | |  x
|---|---|---|
| task.id | |
| task.name | |
| task.outcome | | x
|---|---|---|
| deployment.service.uid | | x
| deployment.service.name | | x
| deployment.service.namespace | | -
| deployment.service.resource_version | | -
| deployment.service.labels | | -
| deployment.target.namespace | | x
| deployment.target.server.url | | x
| deployment.images | | -
|---|---|---|
| vcs.repository.name | | x
| vcs.ref.base.name | | -
| vcs.ref.base.revision | | x
|---|---|---|
| argocd.app.health.status | | x
| argocd.sync.status | |  x
| argocd.sync.operationState.phase | | x
| argocd.sync.operationState.outcome | | -
