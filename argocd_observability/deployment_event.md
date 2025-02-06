### ArgoCD Sync Deployment event

| Property | Source | in Dashboard used | 
|---|---|---|
| event.id  |   |
| event.kind = "SDLC_EVENT" |   | x 
| event.version = "0.1.0" | |  x
| event.category = "task" | |  x
| event.type = "deployment" | |  x
| event.provider = "argocd" | |  x
| event.status = started/finsihed | |  x
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
| deployment.images | This is a list of images. Should be `expanded` to create `artifact.*` properties. Currently, expand operation is not supported by OpenPipeline. | -
|---|---|---|
| vcs.repository.url.full | | x
| vcs.ref.base.name | | -
| vcs.ref.base.revision | | x
|---|---|---|
| argocd.app.health.status | | x
| argocd.sync.status | |  x
| argocd.sync.operation_state.phase | | x
| argocd.sync.operation_state.outcome | | -



## Semantic Dictionary: `artifact.md`

artifact.filename
artifact.id
artifact.name
artifact.version
artifact.purl = scheme:type/namespace/name@version?qualifiers#subpath


### Deployment
#### Semantic Dictionary: `deployment.md`

deployment.release_build_version	
deployment.release_product
deployment.release_stage
deployment.release_version

#### OTEL

deployment.environment.name
deployment.id
deployment.name
deployment.status

+++ (which are not in OTEL)
deployment.namespace
deployment.server.url


|---|---|---|
| deployment.service.uid | app.metadata.uid |
| deployment.service.name | app.metadata.name | 
| deployment.service.namespace | app.metadata.namespace | 
| deployment.service.resource_version | app.metadata.resourceVersion | 
| deployment.service.labels | app.metadata.labels | 

| deployment.environment.name | `staging` (emtpy in case of ArgoCD) | 
| deployment.id | `1234` ?? | 
| deployment.name | `simplenode` ? app.metadata.name? | 
| deployment.namespace | `argocd` status.sync.comparedTo.destination.namespace | 
| deployment.server.url | `https://kubernetes.default.svc` status.sync.comparedTo.destination.server | 

| deployment.images | This is a list of images. Should be `expanded` to create `artifact.*` 