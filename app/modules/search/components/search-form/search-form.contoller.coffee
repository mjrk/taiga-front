###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: search-form.controller.coffee
###

includesAny = (array, values) ->
    for entry in array
        if _.includes(values, entry.id.toString())
            return true
    false


class FilterParamsController

    constructor: ->
        @.filterSpecs ||= {}
        @resetFilterValues()
        @loadFilterSpecs(@.selectedSearchType).then () =>
            @getFilterValuesFromRouteParams()

    resetFilterValues: () ->
        @.filterValues = {}
        if @.selectedSearchType == "text"
            @.params.filter ||= 'all'
        # else
        #     @.params.filter

    isSelectedFilterValue: (param, choice) ->
        @.filterValues[param] ||= []
        _.includes(@.filterValues[param], choice)

    toggleFilterValue: (param, choice) ->
        @.filterValues[param] ||= []
        if @isSelectedFilterValue(param, choice)
            @removeFilterValue(param, choice)
        else
            @setFilterValue(param, choice)
        @.callback()

    toggleAllFilterValues: (filterSpec, negated_choice) ->
        param = filterSpec.param
        @.filterValues[param] ||= []
        if @.filterValues[param]?.length > 0
            if negated_choice?
                idx = @.filterValues[param].indexOf(negated_choice)
                if (
                    idx != -1 or
                    Object.keys(filterSpec.choices).length != \
                    @.filterValues[param].length + 1
                )
                    @.filterValues[param] = (
                        v for v in Object.values(
                            filterSpec.choices
                        ) when v != negated_choice
                    )
                else
                    @.filterValues[param] = [negated_choice]
            else
                @.filterValues[param] = []
        else
            @.filterValues[param] = (
                v for v in Object.values(
                    filterSpec.choices
                ) when v != negated_choice
            )

        @updateFilterValueParam(param)
        @.callback()

    setFilterValue: (param, choice) ->
        @.filterValues[param] ||= []
        @.filterValues[param].push choice
        @updateFilterValueParam(param)

    updateFilterValueParam: (param) ->
        paramValues = @.filterValues[param]
        if paramValues?.length > 0
            @.params[param] = _.flatten(
                (
                    e.id for e in c.details
                ) for c in paramValues
            ).join(",")
        else
            @.params[param] = null

    getFilterValuesFromRouteParams: () ->
        for filterSpec in @currentFilterSpecs()
            if @routeParams[filterSpec.param]?
                values = @routeParams[filterSpec.param].split(",")
                @.filterValues[filterSpec.param] = (
                    c for c in Object.values(
                        filterSpec.choices
                    ) when includesAny(c.details, values)
                )

    removeFilterValue: (param, choice) ->
        @.filterValues[param] ||= []
        _.remove(@.filterValues[param], choice)
        @updateFilterValueParam(param)

    loadFilterSpecs: (type=@.selectedSearchType) ->
        method = "get#{_.capitalize(type)}FilterParams"
        filters = @.filterSpecs[type] or []

        if @.filterSpecs[type]? or not @[method]?
            @$q.when(filters)
        else
            @[method]().then (result) =>
                @.filterSpecs[type] = result

    currentFilterSpecs: () ->
        @.filterSpecs[@.selectedSearchType] or []

    getIssuesFilterParams: () ->
        @$q.all(@commonFilters([
            @filterParams.getIssueTypeMap(),
            @filterParams.getIssueSeverityMap(),
            @filterParams.getIssuePriorityMap(),
            @filterParams.getIssueStatusMap(),
        ]))

    getTasksFilterParams: () ->
        @$q.all(@commonFilters([
            @filterParams.getTaskStatusMap(),
            @filterParams.getDateFilter(
                "Sprint start", "milestone__estimated_start"
            ),
            @filterParams.getDateFilter(
                "Sprint end", "milestone__estimated_end"
            ),
        ]))

    getUserstoriesFilterParams: () ->
        @$q.all(@commonFilters([
            @filterParams.getUserstoryStatusMap(),
            @filterParams.getDateFilter(
                "Sprint start", "milestone__estimated_start"
            ),
            @filterParams.getDateFilter(
                "Sprint end", "milestone__estimated_end"
            ),
        ]))

    getSprintsFilterParams: () ->
        @$q.all(@commonFilters([
            @filterParams.getDateFilter("Start", "estimated_start"),
            @filterParams.getDateFilter("End", "estimated_end"),
        ], "sprints"))

    commonFilters: (moreFilters, model) ->
        moreFilters.concat _.compact([
            @filterParams.getDateFilter("Created", "created_date"),
            @filterParams.getDateFilter("Modified", "modified_date"),
            @filterParams.getUserMap() if model != "sprints"
        ])


class SearchFormController extends FilterParamsController
    @.$inject = [
        '$q',
        '$tgLocation',
        '$tgNavUrls',
        '$routeParams',
        '$tgSearchFilterParamsProvider'
    ]

    constructor: (
        @$q, @location, @navUrls, @routeParams, @filterParams
    ) ->
        @.searchTypes =
            text: "SEARCH.SEARCH_TEXT"
            issues: "SEARCH.FILTER_ISSUES"
            tasks: "SEARCH.FILTER_TASKS"
            userstories: "SEARCH.FILTER_USER_STORIES"
            sprints: "SEARCH.FILTER_SPRINTS"

        @.selectedSearchType = @routeParams.result_type or "text"

        @.params = angular.copy(@routeParams)
        super

    paramsChanged: () ->
        if @.selectedSearchType != @routeParams.result_type
            return true
        for k, v of @.params
            if v?
                if k == "storedSearchName"
                    continue
                if v != @routeParams[k]
                    return true
        false

    getFiltersTemplate: () ->
        if @.selectedSearchType == "text"
            "search/components/search-form/text-search-params.html"
        else
            "search/components/search-form/filtered-search-params.html"

    selectSearchType: (type) ->
        @loadFilterSpecs(type).then =>
            @.selectedSearchType = type
            @resetParams()

    getDateSelector: (type) ->
        selectDate = (params) =>
            dateGte = params["dateGte"]
            dateLte = params["dateLte"]
            changed = false
            update = {}
            update[type + "__gte"] = dateGte
            update[type + "__lte"] = dateLte

            for key of update
                update[key] ||= null
                @.params[key] ||= null
                if @.params[key] != update[key]
                    @.params[key] = update[key]
                    changed = true

            if changed
                @callback()
        return selectDate

    resetParams: () ->
        @.params = {}
        @resetFilterValues()

    selectFilter: (filter) ->
        @.params.filter = filter
        @.callback()

    toggleItemType: (itemType) ->
        index = @.params.item_types.indexOf(itemType)
        if index == -1
            @.params.item_types.push(itemType)
        else
            @.params.item_types.splice(index, 1)

    submitFilter: ->
        @.callback()

    currentResultType: ->
        @routeParams.result_type

    callback: (params) ->

        params = params or @.params
        for k, v of params
            if not v?.length
                params[k] = null

        @.params['order_by'] = @routeParams['order_by']

        if not @.searchTypes[@.selectedSearchType]?
            return
        result_type = {result_type: @.selectedSearchType}

        onChange = @.onChange()
        # TODO find the appropriate way to update url param without
        # reloading
        if @currentResultType() == @.selectedSearchType and onChange?
            @location.search(params)
            onChange(params)
        else
            url = @navUrls.resolve("search-results", result_type)
            delete params['result_type']
            @location.search(params).path(url)

angular.module("taigaSearch").controller("SearchForm", SearchFormController)
