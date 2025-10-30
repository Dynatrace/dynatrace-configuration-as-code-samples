resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_gitlab_deployment" {
  display_name = local.deployment_pipeline_display_name
  custom_id    = local.deployment_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(status)
        DQL
        description = "add event.status"
        id          = "processor_add_event_status"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd event.status = if(status == "running", "started", else: if(status != "running", "finished"))
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(status) and status == "running"
        DQL
        description = "add start_time"
        id          = "processor_add_start_time"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd start_time = toTimestamp(status_changed_at)
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(status) and status != "running"
        DQL
        description = "add end_time"
        id          = "processor_add_end_time"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd end_time = toTimestamp(status_changed_at)
            | fieldsAdd task.outcome = status
          DQL
        }
      }
      processor {
        type        = "fieldsAdd"
        matcher     = "true"
        description = "add task.name"
        id          = "processor_add_task_name"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "task.name"
              value = "GitLab Deployment"
            }
          }
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "deployment"
        DQL
        description = "add deployment properties"
        id          = "processor_add_deployment_properties"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd task.id = deployment_id
            | fieldsAdd deployment.environment.name = environment
            | fieldsAdd deployment.url.full = deployable_url
            | fieldsAdd ext.deployment.job.id = deployable_id
            | fieldsAdd vcs.ref.base.revision = short_sha
            | fieldsAdd vcs.ref.base.name = ref
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(project)
        DQL
        description = "add project properties"
        id          = "processor_add_project_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON:project_j"
            | fieldsAdd ext.project.id = project_j[id]
            | fieldsAdd vcs.repository.url.full = project_j[web_url]
            | fieldsAdd vcs.repository.name = project_j[name]
            | fieldsRemove project_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(task.outcome)
        DQL
        description = "add task.outcome"
        id          = "processor_add_task_outcome"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd task.outcome = if(task.outcome == "failed", "failure", else:task.outcome)
          DQL
        }
      }
      processor {
        type        = "fieldsRemove"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_fields_remove"
        enabled     = true
        fields_remove {
          fields = [
            "object_kind",
            "status",
            "status_changed_at",
            "deployment_id",
            "deployable_id",
            "deployable_url",
            "environment",
            "environment_tier",
            "environment_slug",
            "environment_external_url",
            "project",
            "short_sha",
            "user",
            "user_url",
            "commit_url",
            "commit_title"
          ]
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
        matcher     = <<-DQL
          isNotNull(object_attributes)
        DQL
        description = "add object attribute properties"
        id          = "processor_add_object_attribute_properties"
        enabled     = true
        dql {
          script = <<-DQL
          parse object_attributes, "JSON:obj_attr_j"
          | fieldsAdd duration = if(obj_attr_j[state] == "merged" and obj_attr_j[action] == "merge", toDuration(toTimestamp(obj_attr_j[updated_at]) - toTimestamp(obj_attr_j[created_at])), else: toDuration(0))
          | fieldsAdd event.status = obj_attr_j[state]
          | fieldsAdd start_time = toTimestamp(obj_attr_j[created_at])
          | fieldsAdd end_time = if(in(obj_attr_j[state], {"merged", "closed"}) and in(obj_attr_j[action], {"close", "merge"}), toTimestamp(obj_attr_j[updated_at]))
          | fieldsAdd task.id = obj_attr_j[id]
          | fieldsAdd vcs.change.id = obj_attr_j[iid]
          | fieldsAdd vcs.change.title = obj_attr_j[title]
          | fieldsAdd vcs.repository.ref.revision = obj_attr_j[merge_commit_sha]
          | fieldsAdd vcs.ref.head.name = obj_attr_j[source_branch]
          | fieldsAdd vcs.ref.head.revision = obj_attr_j[last_commit][id]
          | fieldsAdd vcs.ref.base.name = obj_attr_j[target_branch]
          | fieldsAdd ext.task.action = obj_attr_j[action]
          | fieldsAdd ext.task.action.made_at = toTimestamp(obj_attr_j[updated_at])
          | fieldsAdd vcs.change.url.full = obj_attr_j[url]
          | fieldsRemove obj_attr_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(project)
        DQL
        description = "add repository properties"
        id          = "processor_add_repository_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON:project_j"
            | fieldsAdd vcs.repository.name = project_j[name]
            | fieldsAdd vcs.repository.url.full = project_j[web_url]
            | fieldsRemove project_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(labels)
        DQL
        description = "add ext.task.labels"
        id          = "processor_add_ext_task_labels"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd ext.task.labels = labels
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(user)
        DQL
        description = "add ext.task.sender.name"
        id          = "processor_add_ext_task_sender_name"
        enabled     = true
        dql {
          script = <<-DQL
            parse user, "JSON:user_j"
            | fieldsAdd ext.task.sender.name = user_j[name]
            | fieldsRemove user_j
          DQL
        }
      }
      processor {
        type        = "fieldsRemove"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_remove_fields"
        enabled     = true
        fields_remove {
          fields = [
            "object_kind",
            "event_type",
            "user",
            "project",
            "object_attributes",
            "labels",
            "changes",
            "repository"
          ]
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
        matcher     = <<-DQL
          isNotNull(object_attributes)
        DQL
        description = "add object attribute properties"
        id          = "processor_add_object_attribute_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse object_attributes, "JSON:obj_attr_j"
            | fieldsAdd duration = if(isNotNull(obj_attr_j[finished_at]), toDuration(toTimestamp(obj_attr_j[finished_at]) - toTimestamp(obj_attr_j[created_at])), else: toDuration(0))
            | fieldsAdd pipeline.queued.duration = if(isNotNull(obj_attr_j[queued_duration]), toDuration(obj_attr_j[queued_duration]*1000000000), else: toDuration(0))
            | fieldsAdd cicd.pipeline.run.id = obj_attr_j[id]
            | fieldsAdd cicd.pipeline.run.url.full = obj_attr_j[url]
            | fieldsAdd cicd.pipeline.run.trigger = obj_attr_j[source]
            | fieldsAdd vcs.ref.head.name = obj_attr_j[ref]
            | fieldsAdd vcs.ref.head.revision = obj_attr_j[sha]
            | fieldsAdd cicd.pipeline.run.variable = obj_attr_j[variables]
            | fieldsAdd event.status = if(isNotNull(obj_attr_j[finished_at]) and obj_attr_j[status] != "running", "finished", else:obj_attr_j[status])
            | fieldsAdd cicd.pipeline.run.outcome = if(isNotNull(obj_attr_j[finished_at]) and obj_attr_j[status] != "running", obj_attr_j[status])
            | fieldsAdd end_time = if(isNotNull(obj_attr_j[finished_at]) and obj_attr_j[status] != "running", toTimestamp(obj_attr_j[finished_at]))
            | fieldsAdd start_time = if(isNotNull(obj_attr_j[created_at]), toTimestamp(obj_attr_j[created_at]))
            | fieldsAdd cicd.pipeline.name = if(isNotNull(obj_attr_j[name]), obj_attr_j[name], else: "unknown")
            | fieldsRemove obj_attr_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(source_pipeline)
        DQL
        description = "add source pipeline properties"
        id          = "processor_add_source_pipeline_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse source_pipeline, "JSON:src_pipe_j"
            | fieldsAdd cicd.upstream_pipeline.id = src_pipe_j[project][id]
            | fieldsAdd cicd.upstream_pipeline.run.id = src_pipe_j[pipeline_id]
            | fieldsAdd ext.upstream_pipeline.run.job.id = src_pipe_j[job_id]
            | fieldsRemove src_pipe_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(project)
        DQL
        description = "add project properties"
        id          = "processor_add_project_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON:proj_j"
            | fieldsAdd ext.pipeline.project.name = proj_j[name]
            | fieldsAdd ext.pipeline.project.namespace = proj_j[namespace]
            | fieldsAdd vcs.repository.url.full = proj_j[web_url]
            | fieldsAdd vcs.repository.name = proj_j[name]
            | fieldsAdd cicd.pipeline.id = proj_j[id]
            | fieldsRemove proj_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(merge_request)
        DQL
        description = "add vcs.change.id"
        id          = "processor_add_vcs_change_id"
        enabled     = true
        dql {
          script = <<-DQL
            parse merge_request, "JSON:mr_j"
            | fieldsAdd vcs.change.id = mr_j[iid]
            | fieldsRemove mr_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(user)
        DQL
        description = "add ext.pipeline.run.trigger.user"
        id          = "processor_add_ext_pipeline_run_trigger_user"
        enabled     = true
        dql {
          script = <<-DQL
            parse user, "JSON:user_j"
            | fieldsAdd ext.pipeline.run.trigger.user = user_j
            | fieldsRemove user_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(cicd.pipeline.run.outcome)
        DQL
        description = "add cicd.pipeline.run.outcome"
        id          = "processor_add_cicd_pipeline_run_outcome"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd cicd.pipeline.run.outcome = if(cicd.pipeline.run.outcome == "failed", "failure", else:cicd.pipeline.run.outcome)
          DQL
        }
      }
      processor {
        type        = "fieldsRemove"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_remove_fields"
        enabled     = true
        fields_remove {
          fields = [
            "object_kind",
            "object_attributes",
            "merge_request",
            "user",
            "project",
            "commit",
            "source_pipeline",
            "builds"
          ]
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
        matcher     = <<-DQL
          object_kind == "build"
        DQL
        description = "add build task properties"
        id          = "processor_add_build_task_properties"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd event.status = if(isNotNull(build_finished_at) and build_status != "running", "finished", else:build_status)
            | fieldsAdd duration = if(isNotNull(build_duration), toDuration(build_duration*1000000000), else: toDuration(0))
            | fieldsAdd task.queued.duration = if(isNotNull(build_queued_duration), toDuration(build_queued_duration*1000000000), else: toDuration(0))
            | fieldsAdd task.outcome = if(isNotNull(build_finished_at) and build_status != "running", build_status)
            | fieldsAdd cicd.pipeline.run.id = pipeline_id
            | fieldsAdd task.id = build_id
            | fieldsAdd task.name = build_name
            | fieldsAdd task.retry = retries_count
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "build" and build_status == "running" and isNotNull(build_started_at)
        DQL
        description = "add start_time"
        id          = "processor_add_start_time"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd start_time = toTimestamp(build_started_at)
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "build" and build_status != "running" and isNotNull(build_finished_at)
        DQL
        description = "add end_time"
        id          = "processor_add_end_time"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd end_time = toTimestamp(build_finished_at)
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "build" and build_status == "failed"
        DQL
        description = "add task.outcome.failure.reason"
        id          = "processor_add_task_outcome_failure_reason"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd task.outcome.failure.reason = build_failure_reason
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "build" and isNotNull(environment)
        DQL
        description = "add ext.task.build.environment"
        id          = "processor_add_ext_task_build_environment"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd ext.task.build.environment = environment
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(project)
        DQL
        description = "add vcs.repository.name"
        id          = "processor_add_vcs_repository_name"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON:proj_j"
            | fieldsAdd vcs.repository.name = proj_j[name]
            | fieldsRemove proj_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(runner)
        DQL
        description = "add task.runner.name"
        id          = "processor_add_task_runner_name"
        enabled     = true
        dql {
          script = <<-DQL
            parse runner, "JSON:runner_j"
            | fieldsAdd task.runner.name = runner_j[description]
            | fieldsRemove runner_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "build" and isNotNull(build_stage)
        DQL
        description = "add ext.task.stage.name"
        id          = "processor_add_ext_task_stage_name"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd ext.task.stage.name = build_stage
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(task.outcome)
        DQL
        description = "mappings"
        id          = "processor_map_task_outcome"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd task.outcome = if(task.outcome == "failed", "failure", else:task.outcome)
          DQL
        }
      }
      processor {
        type        = "fieldsRemove"
        matcher     = <<-DQL
          object_kind == "build"
        DQL
        description = "Clean"
        id          = "processor_fields_remove"
        enabled     = true
        fields_remove {
          fields = [
            "runner",
            "project_id",
            "project_name",
            "user",
            "commit",
            "repository",
            "project",
            "environment",
            "object_kind",
            "ref",
            "tag",
            "before_sha",
            "sha",
            "retries_count",
            "build_id",
            "build_name",
            "build_stage",
            "build_status",
            "build_created_at",
            "build_started_at",
            "build_finished_at",
            "build_duration",
            "build_queued_duration",
            "build_allow_failure",
            "build_failure_reason",
            "pipeline_id",
            "build_created_at_iso",
            "build_started_at_iso",
            "build_finished_at_iso"
          ]
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
        matcher     = <<-DQL
          isNotNull(action)
        DQL
        description = "add event.status"
        id          = "processor_add_event_status"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd event.status = concat(action, "d")
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "release" and action == "create"
        DQL
        description = "add start_time"
        id          = "processor_add_start_time"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd start_time = toTimestamp(created_at)
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          object_kind == "release"
        DQL
        description = "add release properties"
        id          = "processor_add_release_properties"
        enabled     = true
        dql {
          script = <<-DQL
            fieldsAdd task.id = id
            | fieldsAdd task.name = "GitLab Release"
            | fieldsAdd release.name = name
            | fieldsAdd release.description = description
            | fieldsAdd release.url.full = url
            | fieldsAdd vcs.ref.base.name = tag
            | fieldsAdd ext.release.time = toTimestamp(released_at)
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(commit)
        DQL
        description = "add vcs.ref.base.revision"
        id          = "processor_add_vcs_ref_base_revision"
        enabled     = true
        dql {
          script = <<-DQL
            parse commit, "JSON:commit_j"
            | fieldsAdd vcs.ref.base.revision = commit_j[id]
            | fieldsRemove commit_j
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = <<-DQL
          isNotNull(project)
        DQL
        description = "add project properties"
        id          = "processor_add_project_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse project, "JSON:project_j"
            | fieldsAdd ext.project.id = project_j[id]
            | fieldsAdd vcs.repository.url.full = project_j[web_url]
            | fieldsAdd vcs.repository.name = project_j[name]
            | fieldsRemove project_j
          DQL
        }
      }
      processor {
        type        = "fieldsRemove"
        matcher     = "true"
        description = "Clean up"
        id          = "processor_fields_remove"
        enabled     = true
        fields_remove {
          fields = [
            "id",
            "created_at",
            "description",
            "name",
            "released_at",
            "tag",
            "object_kind",
            "project",
            "url",
            "action",
            "assets",
            "commit"
          ]
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
