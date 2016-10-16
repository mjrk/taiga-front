
taiga = @.taiga

generateHash = taiga.generateHash

searchFilterParamsProvider = ($repo, $model, $storage) ->
    service = {}

    getStatusMap = (model) ->
        return $repo.queryMany("#{model}-statuses").then (result) ->
            status_map = {}
            for status_description in result
                key = status_description.name.toLowerCase()
                if not status_map[key]
                    status_map[key] =
                      name: status_description.name
                      slug: status_description.slug
                      details: []
                status_map[key].details.push status_description

            name: "Status"
            param: "status"
            choices: status_map

    getTypesMap = (model) ->
        return $repo.queryMany("#{model}-types").then (result) ->
            status_map = {}
            for status_description in result
                key = status_description.name.toLowerCase()
                if not status_map[key]
                    status_map[key] =
                      name: status_description.name
                      slug: status_description.slug
                      details: []
                status_map[key].details.push status_description

            name: "Type"
            param: "type"
            choices: status_map

    defineMethod = (method, model) ->
        () -> method(model)

    for model in ["issue", "userstory", "task"]
        service["get#{_.capitalize(model)}StatusMap"] = \
            defineMethod(getStatusMap, model)

    service["getIssueTypeMap"] = defineMethod(getTypesMap, "issue")

    service

module = angular.module("taigaSearch")
module.factory("$tgSearchFilterParamsProvider", [
    "$tgRepo", "$tgModel", "$tgStorage", searchFilterParamsProvider
])
