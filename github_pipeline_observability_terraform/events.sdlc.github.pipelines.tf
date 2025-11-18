resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_github_pull_request" {
  display_name = local.pull_request_pipeline_display_name
  custom_id    = local.pull_request_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = "isNotNull(pull_request)"
        description = "Add pull request properties"
        id          = "processor_add_pull_request_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse pull_request,
              "JSON{
                BOOLEAN:merged,
                STRING:state,
                STRING:merged_at,
                STRING:created_at,
                LONG:id,
                STRING:title,
                STRING[]:labels,
                LONG:number,
                STRING:html_url,
                JSON{
                  STRING:ref,
                  STRING:sha
                }:head,
                JSON{
                  STRING:ref,
                  STRING:sha
                }:base
              }:pr"
            | fieldsFlatten pr,
              fields:{
                merged,
                state,
                merged_at,
                created_at,
                id,
                title,
                labels,
                number,
                html_url,
                head,
                base
              }

            | fieldsAdd event.status = if(merged == true, "finished", else: if(state == "closed", "finished", else: "started"))
            | fieldsAdd duration = if((merged_at > created_at) and event.status == "finished", toTimestamp(merged_at) - toTimestamp(created_at), else: toDuration(0))
            | fieldsAdd start_time = toTimestamp(created_at)
            | fieldsAdd end_time = if(merged == true, toTimestamp(merged_at), else: if(state == "closed", toTimestamp(closed_at)))

            | fieldsAdd task.title = concat("[Change Request]", " ", title)
            | fieldsAdd task.labels = toArray(labels)
            | fieldsAdd task.outcome = if(action == "closed" and merged == true, "success")
            | fieldsAdd vcs.ref.head.name = head[ref]
            | fieldsAdd vcs.ref.head.revision = head[sha]
            | fieldsAdd vcs.ref.base.name = base[ref]
            | fieldsAdd vcs.ref.base.revision = base[sha]

            | fieldsRemove pr, merged, state, merged_at, created_at, labels, head, base

            | fieldsRename task.id = id
            | fieldsRename vcs.change.id = number
            | fieldsRename vcs.change.title = title
            | fieldsRename vcs.change.state = action
            | fieldsRename vcs.change.url.full = html_url
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(repository)"
        description = "Add repository properties"
        id          = "processor_add_repository_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse repository, "JSON{STRING:full_name, STRING:html_url}:repo"
            | fieldsFlatten repo, fields:{full_name, html_url}
            | fieldsRename vcs.repository.name = full_name
            | fieldsRename vcs.repository.url.full = html_url
            | fieldsRemove repo
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
              task.title,
              task.labels,
              task.outcome,
              vcs.ref.head.revision,
              vcs.ref.head.name,
              vcs.ref.base.revision,
              vcs.ref.base.name,
              task.id,
              vcs.change.id,
              vcs.change.title,
              vcs.change.state,
              vcs.change.url.full,
              vcs.repository.name,
              vcs.repository.url.full
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

resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_github_workflow" {
  display_name = local.workflow_pipeline_display_name
  custom_id    = local.workflow_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = "isNotNull(workflow_run)"
        description = "Add workflow run properties"
        id          = "processor_add_workflow_run_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse workflow_run,
              "JSON{
                STRING:status,
                STRING:updated_at,
                STRING:run_started_at,
                LONG:id,
                STRING:html_url,
                STRING:event,
                LONG:run_attempt,
                STRING:conclusion,
                STRING:head_sha,
                STRING:head_branch
              }:run"
            | fieldsFlatten run,
              fields:{
                status,
                updated_at,
                run_started_at,
                id,
                html_url,
                event,
                run_attempt,
                conclusion,
                head_sha,
                head_branch
              }

            | fieldsAdd event.status = if(status == "in_progress", "started", else: if(status == "completed", "finished", else: status))
            | fieldsAdd duration = if((updated_at > run_started_at) and event.status == "finished", toTimestamp(updated_at) - toTimestamp(run_started_at), else: toDuration(0))
            | fieldsAdd start_time = toTimestamp(run_started_at)
            | fieldsAdd end_time = if(event.status == "finished", toTimestamp(updated_at))

            | fieldsAdd diff2h = toLong(7200000000000)
            | fieldsAdd nt = toLong(toTimestamp(now()))
            | fieldsAdd st = if(nt - toLong(toTimestamp(start_time)) < diff2h, start_time, else: toTimestamp(nt))
            | fieldsAdd et = if(nt - toLong(toTimestamp(end_time)) < diff2h, end_time, else: toTimestamp(nt))
            | fieldsAdd ut = if(nt - toLong(toTimestamp(updated_at)) < diff2h, updated_at, else: toTimestamp(nt))
            | fieldsAdd timestamp = if(event.status == "started", st, else: if(event.status == "finished", et, else: ut))

            | fieldsAdd cicd.pipeline.run.outcome = if (action == "completed" or action == "requested", conclusion)

            | fieldsRemove run, status, updated_at, run_started_at, st, et, ut, nt, diff2h, conclusion

            | fieldsRename cicd.pipeline.run.id = id
            | fieldsRename cicd.pipeline.run.url.full = html_url
            | fieldsRename cicd.pipeline.run.trigger = event
            | fieldsRename cicd.pipeline.run.attempt = run_attempt
            | fieldsRename vcs.ref.head.revision = head_sha
            | fieldsRename vcs.ref.head.name = head_branch
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(workflow)"
        description = "Add cicd pipeline properties"
        id          = "processor_add_cicd_pipeline_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse workflow, "JSON{STRING:id, STRING:name, STRING:html_url}:workflow"
            | fieldsFlatten workflow, fields:{id, name, html_url}
            | fieldsRename cicd.pipeline.id = id
            | fieldsRename cicd.pipeline.name = name
            | fieldsRename cicd.pipeline.url.full = html_url
            | fieldsRemove workflow
          DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(repository)"
        description = "Add repository properties"
        id          = "processor_add_repository_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse repository, "JSON{STRING:full_name, STRING:html_url}:repo"
            | fieldsFlatten repo, fields:{full_name, html_url}
            | fieldsRename vcs.repository.name = full_name
            | fieldsRename vcs.repository.url.full = html_url
            | fieldsRemove repo
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
              cicd.pipeline.id,
              cicd.pipeline.name,
              cicd.pipeline.url.full,
              cicd.pipeline.run.id,
              cicd.pipeline.run.url.full,
              cicd.pipeline.run.trigger,
              cicd.pipeline.run.attempt,
              cicd.pipeline.run.outcome,
              vcs.repository.name,
              vcs.repository.url.full,
              vcs.ref.head.revision,
              vcs.ref.head.name
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

resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_github_job" {
  display_name = local.job_pipeline_display_name
  custom_id    = local.job_pipeline_custom_id
  processing {
    processors {
      processor {
        type        = "dql"
        matcher     = "isNotNull(workflow_job)"
        description = "Add pipeline properties"
        id          = "processor_add_pipeline_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse workflow_job,
              "JSON{
                STRING:status,
                STRING:started_at,
                STRING:created_at,
                STRING:completed_at,
                STRING:updated_at,
                LONG:run_id,
                LONG:id,
                STRING:name,
                LONG:run_attempt,
                JSON_ARRAY:steps,
                STRING[]:labels,
                STRING:runner_name,
                STRING:runner_group_name,
                STRING:conclusion,
                STRING:head_branch,
                STRING:head_sha
              }:job"
            | fieldsFlatten job, fields: {status, started_at, created_at, completed_at, updated_at, run_id, id, name, run_attempt, steps, labels, runner_name, runner_group_name, conclusion, head_branch, head_sha}

            | fieldsAdd event.status = if(status == "in_progress", "started", else: if(status == "completed", "finished", else: status))
            | fieldsAdd duration = if((started_at > created_at) and event.status == "finished", toTimestamp(started_at) - toTimestamp(created_at), else: toDuration(0))
            | fieldsAdd start_time = if (event.status == "started", toTimestamp(created_at))
            | fieldsAdd end_time = if (event.status == "finished", toTimestamp(completed_at))

            | fieldsAdd diff2h = toLong(7200000000000)
            | fieldsAdd nt = toLong(toTimestamp(now()))
            | fieldsAdd st = if(nt - toLong(toTimestamp(start_time)) < diff2h, start_time, else: toTimestamp(nt))
            | fieldsAdd et = if(nt - toLong(toTimestamp(end_time)) < diff2h, end_time, else: toTimestamp(nt))
            | fieldsAdd timestamp = if(event.status == "started", st, else: if(event.status == "finished", et, else: toTimestamp(nt)))

            | fieldsAdd task.outcome = if(action == "completed", conclusion)

            | fieldsRename cicd.pipeline.run.id = run_id
            | fieldsRename task.id = id
            | fieldsRename task.name = name
            | fieldsRename task.run.attempt = run_attempt
            | fieldsRename task.steps = steps
            | fieldsRename task.labels = labels
            | fieldsRename task.runner.name = runner_name
            | fieldsRename task.runner.group.name = runner_group_name
            | fieldsRename vcs.ref.head.revision = head_sha
            | fieldsRename vcs.ref.head.name = head_branch

            | fieldsRemove job, status, started_at, created_at, updated_at, st, et, nt, diff2h, conclusion
        DQL
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNotNull(repository)"
        description = "Add repository properties"
        id          = "processor_add_repository_properties"
        enabled     = true
        dql {
          script = <<-DQL
            parse repository,
              "JSON{
                STRING:full_name,
                STRING:html_url
              }:repo"
            | fieldsFlatten repo
            | fieldsRename vcs.repository.name = repo.full_name
            | fieldsRename vcs.repository.url.full = repo.html_url
            | fieldsRemove repo
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
              task.outcome,
              cicd.pipeline.run.id,
              task.id,
              task.name,
              task.run.attempt,
              task.steps,
              task.labels,
              task.runner.name,
              task.runner.group.name,
              vcs.ref.head.revision,
              vcs.ref.head.name,
              vcs.repository.name,
              vcs.repository.url.full
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
