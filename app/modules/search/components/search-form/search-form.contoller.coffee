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

class SearchFormController
    @.$inject = [
        '$tgLocation',
        '$tgNavUrls',
        '$routeParams'
    ]

    constructor: (
        @location, @navUrls, @routeParams
    ) ->
        @.searchTypes =
            text: "SEARCH.SEARCH_TEXT"
            issues: "SEARCH.FILTER_ISSUES"
            tasks: "SEARCH.FILTER_TASKS"
            userstories: "SEARCH.FILTER_USER_STORIES"
            sprints: "SEARCH.FILTER_SPRINTS"

        @.selectedSearchType = @routeParams.result_type or "text"

        @.params = angular.copy(@routeParams)
        @.params.filter ||= 'all'

    getFiltersTemplate: () ->
        if @.selectedSearchType == "text"
            "search/components/search-form/text-search-params.html"
        else
            "search/components/search-form/filtered-search-params.html"

    selectSearchType: (type) ->
        @.selectedSearchType = type

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
