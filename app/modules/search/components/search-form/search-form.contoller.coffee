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

    toggleAllFilterValues: (filterSpec) ->
        param = filterSpec.param
        @.filterValues[param] ||= []
        if @.filterValues[param]?.length > 0
            @.filterValues[param] = []
        else
            @.filterValues[param] = Object.values(filterSpec.choices)
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
            @q.when(filters)
        else
            @[method]().then (result) =>
                @.filterSpecs[type] = result

    currentFilterSpecs: () ->
        @.filterSpecs[@.selectedSearchType] or []

    getIssuesFilterParams: () ->
        @q.all([
            @filterParams.getIssueTypeMap(),
            @filterParams.getIssueStatusMap()
        ])

    getTasksFilterParams: () ->
        @filterParams.getTaskStatusMap().then (result) ->
            [
                result
            ]

    getUserstoriesFilterParams: () ->
        @filterParams.getUserstoryStatusMap().then (result) ->
            [
                result
            ]

    # getSprintsFilterParams: () ->
    #     @filterParams.getIssueStatusMap().then (result) ->
    #         [
    #             name: "Status"
    #             choices: result
    #         ]


class SearchFormController extends FilterParamsController
    @.$inject = [
        '$q',
        '$tgLocation',
        '$tgNavUrls',
        '$routeParams',
        '$tgSearchFilterParamsProvider'
    ]

    constructor: (
        @q, @location, @navUrls, @routeParams, @filterParams
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

    getFiltersTemplate: () ->
        if @.selectedSearchType == "text"
            "search/components/search-form/text-search-params.html"
        else
            "search/components/search-form/filtered-search-params.html"

    selectSearchType: (type) ->
        @loadFilterSpecs(type).then =>
            @.selectedSearchType = type
            @resetParams()

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
