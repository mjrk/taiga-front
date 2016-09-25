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
# File: search-results.controller.coffee
###

class SearchResults
    @.$inject = [
        '$routeParams',
        'tgSearchResultsService',
        '$route',
        'tgAppMetaService',
        '$translate'
    ]

    constructor: (@routeParams, @searchResultsService, @route, @appMetaService, @translate) ->
        @.page = 1

        # taiga.defineImmutableProperty @, "searchResult", () => return @searchResultsService.searchResult
        # taiga.defineImmutableProperty @, "nextSearchPage", () => return @searchResultsService.nextSearchPage

        @searchResult = null

        # @.q = @routeParams.q
        # @.filter = @routeParams.filter || 'all'
        # @.orderBy = @routeParams['order_by'] || ''

        @.loadingGlobal = false
        @.loadingList = false
        @.loadingPagination = false

        title = @translate.instant("DISCOVER.SEARCH.PAGE_TITLE")
        description = @translate.instant("DISCOVER.SEARCH.PAGE_DESCRIPTION")
        @appMetaService.setAll(title, description)

    getSearchResultsListTemplate: () ->
        result_type = @getResultType()
        "search/search-results/partials/#{result_type}.html"

    getResultType: () ->
        @routeParams.result_type

    getResultCount: () ->
        count = 0
        if @searchResult?
            if Immutable.Iterable.isIterable(@searchResult)
                count = @searchResult.size
            else
                count = @searchResult.length
        count

    getRouteParamsFilter: (name) ->
        @routeParams[name]

    updateRouteParamsFilter: (name, value) ->
        @routeParams[name] = value
        params = {}
        params[name] = value
        @route.updateParams(params)

    updateRouteParamsFilters: (params) ->
        _.assign(@routeParams, params)
        @route.updateParams(params)

    fetch: () ->
        @.page = 1

        @searchResultsService.resetSearchResult()

        return @.search()

    fetchByGlobalSearch: () ->
        return if @.loadingGlobal

        @.loadingGlobal = true

        @.fetch().then () => @.loadingGlobal = false

    fetchList: () ->
        return if @.loadingList

        @.loadingList = true

        @.fetch().then () => @.loadingList = false

    showMore: () ->
        return if @.loadingPagination

        @.loadingPagination = true

        @.page++

        return @.search().then () => @.loadingPagination = false

    search: (params) ->
        if not params?
            params = @routeParams
        return @searchResultsService.fetchSearch(params).then (result) =>
            @.activeParams = angular.copy(params)
            @.searchResult = result
            result

    onChangeFilter: (params) =>
        @updateRouteParamsFilters(params)
        @.fetchList()

    onChangeOrder: (orderBy) ->
        @updateRouteParamsFilter("order_by", orderBy)
        @.fetchList()

angular.module("taigaSearch").controller(
    "SearchResults", SearchResults
)
