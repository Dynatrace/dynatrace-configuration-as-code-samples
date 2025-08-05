### ArgoCD Sync Deployment event

| Property | Source | in Dashboard used | 
|---|---|---|
| event.id  |   |
| event.kind = "SDLC_EVENT" |   | x 
| event.version = "0.1.0" | |  x
| event.category = "task" | |  x
| event.type = "deployment" | |  x
| event.provider = "argocd" | |  x
| event.status = started/finished | |  x
| duration | |  x
| start_time | |  x
| end_time | |  x
| timestamp | |  x
| | | |
| task.id | | -
| task.name | | -
| task.outcome | must be mapped from argocd.sync.status | x
| | | |
| deployment.service.uid | app.metadata.uid | x
| deployment.service.name | app.metadata.name | -
| deployment.service.namespace | app.metadata.namespace | -
| deployment.service.resource_version | app.metadata.resourceVersion | -
| deployment.service.labels | app.metadata.labels | -
| | | |
| deployment.id | app.status.sync.revision | -
| deployment.name | app.metadata.name | x
| deployment.namespace | app.status.sync.comparedTo.destination.namespace | x
| deployment.server.url.full | app.status.sync.comparedTo.destination.server | x
| deployment.environment.name | `undefined` | x
| deployment.ingress.url | app.status.summary.externalURLs | -
| | | |
| vcs.repository.url.full | | x
| vcs.repository.commit.url | | -
| vcs.ref.base.name | | -
| vcs.ref.base.revision | | x
| | | |
| argocd.app.health.status | app.status.health.status | x
| argocd.app.reconciliation.time | app.status.reconciledAt | x
| argocd.app.conditions | app.status.conditions | -
| argocd.app.url | | -
| argocd.app.name | app.metadata.labels.name | x
| argocd.app.stage | app.metadata.labels.stage | -
| argocd.app.owner | app.metadata.labels.owner | -
| argocd.app.version | app.metadata.labels.version | -
| argocd.sync.status | app.status.sync.status |  x
| argocd.sync.operation_state.outcome | app.status.operationState.message | x

<!--| deployment.images | app.status.summary.images, Note: This is a list of images. Should be `expanded` to create `artifact.*` properties. Currently, expand operation is not supported by OpenPipeline. | - -->

### Semantic Dictionary: `artifact.md`

- artifact.filename
- artifact.id
- artifact.name
- artifact.version
- artifact.purl = scheme:type/namespace/name@version?qualifiers#subpath


### Deployment
#### Semantic Dictionary: `deployment.md`

> Note: Leave as is. Mark as internal to be considered as deprecated.

- deployment.release_build_version	
- deployment.release_product
- deployment.release_stage
- deployment.release_version

#### OTel

- deployment.environment.name
- deployment.id
- deployment.name
- deployment.status

+++ (Additional properties that are not in OTEL)
- deployment.namespace
- deployment.server.url
