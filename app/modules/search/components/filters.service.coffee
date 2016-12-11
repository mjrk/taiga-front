
taiga = @.taiga

generateHash = taiga.generateHash

searchFilterParamsProvider = ($repo, $model, $storage) ->
    service =
      forModel: {}

    getStatusMap = (model) ->
        return $repo.queryMany("#{model}-statuses").then (result) ->
            map = {}
            for description in result
                key = description.name.toLowerCase()
                if not map[key]
                    map[key] =
                        name: description.name
                        slug: description.slug
                        details: []
                map[key].details.push description

            r =
              name: "Status"
              param: "status"
              choices: map

            service.forModel[model] ||= {}
            service.forModel[model][r["param"]] = r
            r

    service.getProjectMap = () ->
        return $repo.queryMany("projects").then (result) ->
            map = {}
            for description in result
                key = description.name.toLowerCase()
                if not map[key]
                    map[key] =
                        name: description.name
                        slug: description.slug
                        details: []
                map[key].details.push description

            r =
              name: "Project"
              param: "project"
              choices: map

            service.forModel[model] ||= {}
            service.forModel[model][r["param"]] = r
            r

    getGenericMap = (model, resource, param) ->
        label = _.capitalize(param)
        return $repo.queryMany(resource).then (result) ->
            map = {}
            for description in result
                key = description.name.toLowerCase()
                if not map[key]
                    map[key] =
                      name: description.name
                      slug: description.slug
                      details: []
                map[key].details.push description

            r =
                name: label
                param: param
                choices: map

            service.forModel[model] ||= {}
            service.forModel[model][r["param"]] = r
            r

    defineMethod = (method) ->
        args = Array.prototype.slice.call(arguments).slice(1)
        () -> method.apply(null, args)

    for model in ["issue", "userstory", "task"]
        service["get#{_.capitalize(model)}StatusMap"] = \
            defineMethod(getStatusMap, model)

    service["getIssueTypeMap"] = defineMethod(
        getGenericMap, "issue", "issue-types", "type"
    )
    service["getIssueSeverityMap"] = defineMethod(
        getGenericMap, "issue", "severities", "severity"
    )
    service["getIssuePriorityMap"] = defineMethod(
        getGenericMap, "issue", "priorities", "priority"
    )

    service.getDateFilter = (name, param) ->
        name: name
        param: param
        date: true

    service.getUserMap = () ->
        return $repo.queryMany("users").then (result) ->
            map = {}
            for description in result
                key = description.full_name.toLowerCase()
                if not map[key]
                    map[key] =
                      name: description.full_name_display
                      username: description.username
                      id: description.id
                      details: []
                map[key].details.push description

            name: "Assignee"
            param: "assigned_to"
            choices: map

    service

module = angular.module("taigaSearch")
module.factory("$tgSearchFilterParamsProvider", [
    "$tgRepo", "$tgModel", "$tgStorage", searchFilterParamsProvider
])
