resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_gitlab_deployment" {
  display_name = local.deployment_pipeline_display_name
  custom_id    = local.deployment_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = true
        description = "Add deployment properties"
        id          = "processor_add_deployment_properties"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd task.name = "GitLab Deployment"
            | fieldsAdd event.status = if(status == "running", "started", else: "finished")
            | fieldsAdd start_time = if (event.status == "started", toTimestamp(status_changed_at))
            | fieldsAdd end_time = if(isNotNull(status) and status != "running", toTimestamp(status_changed_at))
            | fieldsAdd task.outcome = if(status == "failed", "failure", else: if (status != "running", status))

            | fieldsRename task.id = deployment_id
            | fieldsRename deployment.environment.name = environment
            | fieldsRename deployment.url.full = deployable_url
            | fieldsRename ext.deployment.job.id = deployable_id
            | fieldsRename vcs.ref.base.revision = short_sha
            | fieldsRename vcs.ref.base.name = ref
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(project)"
        description = "Add project properties"
        id          = "processor_add_project_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project,
              "JSON{
                LONG:id,
                STRING:web_url,
                STRING:name
              }:project"
            | fieldsFlatten project, fields: { id, web_url, name }

            | fieldsRename ext.project.id = id
            | fieldsRename vcs.repository.url.full = web_url
            | fieldsRename vcs.repository.name = name

            | fieldsRemove project
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_clean_up"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsKeep
              event.kind,
              event.status,
              event.id,
              event.provider,
              event.category,
              event.type,
              event.version,
              start_time,
              end_time,
              timestamp,
              task.outcome,
              ext.project.id,
              vcs.repository.url.full,
              vcs.repository.name,
              task.id,
              deployment.environment.name,
              deployment.url.full,
              ext.deployment.job.id,
              vcs.ref.base.revision,
              vcs.ref.base.name
          DQL
        }
      }
    }
  }
  security_context {}
  cost_allocation {}
  data_extraction {}
  metric_extraction {}
  product_allocation {}
  storage {}
  davis {}
}

resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_gitlab_merge_request" {
  display_name = local.merge_request_pipeline_display_name
  custom_id    = local.merge_request_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = "isNotNull(object_attributes)"
        description = "add object attribute properties"
        id          = "processor_add_object_attribute_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse object_attributes,
              "JSON{
                STRING:state,
                STRING:action,
                STRING:updated_at,
                STRING:created_at,
                LONG:id,
                LONG:iid,
                STRING:title,
                STRING:merge_commit_sha,
                STRING:source_branch,
                STRING:target_branch,
                STRING:url,
                JSON{
                  STRING:id
                }:last_commit
              }:obj"
            | fieldsFlatten obj,
              fields: {
                state,
                action,
                updated_at,
                created_at,
                id,
                iid,
                title,
                merge_commit_sha,
                source_branch,
                target_branch,
                url
              }

            | fieldsAdd duration = if(state == "merged" and action == "merge", toDuration(toTimestamp(updated_at) - toTimestamp(created_at)), else: toDuration(0))
            | fieldsAdd start_time = toTimestamp(created_at)
            | fieldsAdd end_time = if(in(state,{"merged","closed"}) and in(action, {"close","merge"}), toTimestamp(updated_at))
            | fieldsAdd ext.task.action.made_at = toTimestamp(updated_at)
            | fieldsAdd vcs.ref.head.revision = last_commit[id]

            | fieldsRemove obj, last_commit, updated_at, created_at

            | fieldsRename event.status = state
            | fieldsRename task.id = id
            | fieldsRename vcs.change.id = iid
            | fieldsRename vcs.change.title = title
            | fieldsRename vcs.repository.ref.revision = merge_commit_sha
            | fieldsRename vcs.ref.head.name = source_branch
            | fieldsRename vcs.ref.base.name = target_branch
            | fieldsRename ext.task.action = action
            | fieldsRename vcs.change.url.full = url
            | fieldsRename ext.task.labels = labels
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(project)"
        description = "add repository properties"
        id          = "processor_add_repository_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON{STRING:name, STRING:web_url}:project"
            | fieldsFlatten project, fields: { name, web_url }

            | fieldsRename vcs.repository.name = name
            | fieldsRename vcs.repository.url.full = web_url

            | fieldsRemove project
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(user)"
        description = "add ext.task.sender.name"
        id          = "processor_add_ext_task_sender_name"
        enabled     = true
        dql {
          script = <<-DQL
            parse user, "JSON{STRING:name}:user"
            | fieldsFlatten user, fields:{ name }

            | fieldsRename ext.task.sender.name = name

            | fieldsRemove user
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_clean_up"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsKeep
              event.kind,
              event.status,
              event.id,
              event.provider,
              event.category,
              event.type,
              event.version,
              start_time,
              end_time,
              duration,
              timestamp,
              ext.task.action.made_at,
              vcs.ref.head.revision,
              task.id,
              vcs.change.id,
              vcs.change.title,
              vcs.repository.ref.revision,
              vcs.ref.head.name,
              vcs.ref.base.name,
              ext.task.action,
              vcs.change.url.full,
              ext.task.labels,
              vcs.repository.url.full,
              vcs.repository.name,
              ext.task.sender.name
          DQL
        }
      }
    }
  }
  security_context {}
  cost_allocation {}
  data_extraction {}
  metric_extraction {}
  product_allocation {}
  storage {}
  davis {}
}

resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_gitlab_pipeline" {
  display_name = local.workflow_pipeline_display_name
  custom_id    = local.workflow_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = "isNotNull(object_attributes)"
        description = "Add object attribute properties"
        id          = "processor_add_object_attribute_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse object_attributes,
              "JSON{
                STRING:finished_at,
                STRING:created_at,
                LONG:queued_duration,
                STRING:status,
                STRING:name,
                LONG:id,
                STRING:url,
                STRING:source,
                STRING:ref,
                STRING:sha,
                STRING:variables
              }:obj"
            | fieldsFlatten obj,
              fields: {
                finished_at,
                created_at,
                queued_duration,
                status,
                name,
                id,
                url,
                source,
                ref,
                sha,
                variables
              }

            | fieldsAdd duration = if(isNotNull(finished_at), toDuration(toTimestamp(finished_at) - toTimestamp(created_at)), else: toDuration(0))
            | fieldsAdd pipeline.queued.duration = if(isNotNull(queued_duration), toDuration(queued_duration * 1000000000), else: toDuration(0))
            | fieldsAdd event.status = if(isNotNull(finished_at) and status != "running", "finished", else: status)

            | fieldsAdd cicd.pipeline.run.outcome = if(status == "failed", "failure", else: if(isNotNull(finished_at) and status != "running" , status))
            | fieldsAdd end_time = if(isNotNull(finished_at) and status != "running", toTimestamp(finished_at))
            | fieldsAdd start_time = if(isNotNull(created_at), toTimestamp(created_at))
            | fieldsAdd cicd.pipeline.name = if(isNotNull(name), name, else: "unknown")

            | fieldsRemove obj, finished_at, created_at, status, name


            | fieldsRename cicd.pipeline.run.id = id
            | fieldsRename cicd.pipeline.run.url.full = url
            | fieldsRename cicd.pipeline.run.trigger = source
            | fieldsRename vcs.ref.head.name = ref
            | fieldsRename vcs.ref.head.revision = sha
            | fieldsRename cicd.pipeline.run.variable = variables
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(source_pipeline)"
        description = "Add source pipeline properties"
        id          = "processor_add_source_pipeline_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse source_pipeline,
              "JSON{
                JSON{
                  LONG:id
                }:project,
                LONG:pipeline_id,
                LONG:job_id
              }:pipeline"
            | fieldsFlatten pipeline, fields: { project, pipeline_id, job_id}

            | fieldsAdd cicd.upstream_pipeline.id = project[id]

            | fieldsRename cicd.upstream_pipeline.run.id = pipeline_id
            | fieldsRename ext.upstream_pipeline.run.job.id = job_id

            | fieldsRemove pipeline, project
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(project)"
        description = "Add project properties"
        id          = "processor_add_project_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project,
              "JSON{
                STRING:name,
                STRING:namespace,
                STRING:web_url,
                LONG:id
              }:project"
            | fieldsFlatten project,
              fields: {
                name,
                namespace,
                web_url,
                id
              }

            | fieldsAdd ext.pipeline.project.name = name
            | fieldsRename ext.pipeline.project.namespace = namespace
            | fieldsRename vcs.repository.url.full = web_url
            | fieldsRename vcs.repository.name = name
            | fieldsRename cicd.pipeline.id = id

            | fieldsRemove project
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(merge_request)"
        description = "Add merge request properties"
        id          = "processor_add_merge_request_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse merge_request, "JSON{LONG:iid}:merge_request"
            | fieldsAdd vcs.change.id = merge_request[iid]
            | fieldsRemove merge_request
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(user)"
        description = "Add user properties"
        id          = "processor_add_user_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse user, "JSON{LONG:id, STRING:username}:user"
            | fieldsRename ext.pipeline.run.trigger.user = user
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_clean_up"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsKeep
              event.kind,
              event.status,
              event.id,
              event.provider,
              event.category,
              event.type,
              event.version,
              duration,
              start_time,
              end_time,
              timestamp,
              pipeline.queued.duration,
              cicd.pipeline.run.outcome,
              cicd.pipeline.name,
              cicd.pipeline.run.id,
              cicd.pipeline.run.url.full,
              cicd.pipeline.run.trigger,
              vcs.ref.head.name,
              vcs.ref.head.revision,
              cicd.pipeline.run.variable,
              cicd.upstream_pipeline.id,
              cicd.upstream_pipeline.run.id,
              ext.upstream_pipeline.run.job.id,
              ext.pipeline.project.name,
              ext.pipeline.project.namespace,
              vcs.repository.url.full,
              vcs.repository.name,
              cicd.pipeline.id,
              vcs.change.id,
              ext.pipeline.run.trigger.user
          DQL
        }
      }
    }
  }
  security_context {}
  cost_allocation {}
  data_extraction {}
  metric_extraction {}
  product_allocation {}
  storage {}
  davis {}
}

resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_gitlab_job" {
  display_name = local.job_pipeline_display_name
  custom_id    = local.job_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = true
        description = "Add build task properties"
        id          = "processor_add_build_task_properties"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd event.status = if(isNotNull(build_finished_at) and build_status != "running", "finished", else: build_status)
            | fieldsAdd duration = if(isNotNull(build_duration), toDuration(build_duration*1000000000), else: toDuration(0))
            | fieldsAdd task.queued.duration = if(isNotNull(build_queued_duration), toDuration(build_queued_duration*1000000000), else: toDuration(0))
            | fieldsAdd task.outcome = if(build_status == "failed", "failure", else: if(isNotNull(build_finished_at) and build_status != "running", build_status))
            | fieldsAdd start_time = if(build_status == "running" and isNotNull(build_started_at), toTimestamp(build_started_at))
            | fieldsAdd end_time = if(build_status != "running" and isNotNull(build_finished_at), toTimestamp(build_finished_at))
            | fieldsAdd task.outcome.failure.reason = if(build_status == "failed", build_failure_reason)

            | fieldsRename cicd.pipeline.run.id = pipeline_id
            | fieldsRename task.id = build_id
            | fieldsRename task.name = build_name
            | fieldsRename task.retry = retries_count
            | fieldsRename ext.task.build.environment = environment
            | fieldsRename ext.task.stage.name = build_stage
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(project)"
        description = "Add project properties"
        id          = "processor_add_project_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON{STRING:name}:project"
            | fieldsFlatten project, fields:{ name }

            | fieldsRename vcs.repository.name = name

            | fieldsRemove project
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(runner)"
        description = "Add runner properties"
        id          = "processor_add_runner_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse runner, "JSON{STRING:description}:runner"
            | fieldsFlatten runner, fields: { description }

            | fieldsRename task.runner.name = description

            | fieldsRemove runner
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_clean_up"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsKeep
              event.kind,
              event.status,
              event.id,
              event.provider,
              event.category,
              event.type,
              event.version,
              start_time,
              end_time,
              duration,
              timestamp,
              task.queued.duration,
              task.outcome,
              task.outcome.failure.reason,
              vcs.repository.name,
              cicd.pipeline.run.id,
              task.id,
              task.name,
              task.retry,
              ext.task.build.environment,
              ext.task.stage.name,
              task.runner.name
          DQL
        }
      }
    }
  }
  security_context {}
  cost_allocation {}
  data_extraction {}
  metric_extraction {}
  product_allocation {}
  storage {}
  davis {}
}

resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_gitlab_release" {
  display_name = local.release_pipeline_display_name
  custom_id    = local.release_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = true
        description = "Add release properties"
        id          = "processor_add_release_properties"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd task.name = "GitLab Release"
            | fieldsAdd ext.release.time = toTimestamp(released_at)
            | fieldsAdd start_time = if(action == "create", toTimestamp(created_at))
            | fieldsAdd event.status = if(isNotNull(action), concat(action,"d"))

            | fieldsRename task.id = id
            | fieldsRename release.name = name
            | fieldsRename release.description = description
            | fieldsRename release.url.full = url
            | fieldsRename vcs.ref.base.name = tag
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(commit)"
        description = "Add commit properties"
        id          = "processor_add_commit_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse commit, "JSON{STRING:id}:commit"
            | fieldsFlatten commit, fields:{ id }

            | fieldsRename vcs.ref.base.revision = id

            | fieldsRemove commit
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(project)"
        description = "Add project properties"
        id          = "processor_add_project_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON{LONG:id, STRING:web_url, STRING:name}:project"
            | fieldsFlatten project, fields: { id, web_url, name }

            | fieldsRename ext.project.id = id
            | fieldsRename vcs.repository.url.full = web_url
            | fieldsRename vcs.repository.name = name

            | fieldsRemove project
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_clean_up"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsKeep
              event.kind,
              event.status,
              event.id,
              event.provider,
              event.category,
              event.type,
              event.version,
              start_time,
              timestamp,
              ext.release.time,
              task.id,
              release.name,
              release.description,
              release.url.full,
              vcs.ref.base.name,
              vcs.ref.base.revision,
              ext.project.id,
              vcs.repository.url.full,
              vcs.repository.name
          DQL
        }
      }
    }
  }
  security_context {}
  cost_allocation {}
  data_extraction {}
  metric_extraction {}
  product_allocation {}
  storage {}
  davis {}
}
