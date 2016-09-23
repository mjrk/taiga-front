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
# File: search.service.coffee
###

taiga = @.taiga

class SearchResultsService extends taiga.Service
    @.$inject = [
          "SearchTypeText",
          "SearchTypeFiltered"
    ]

    constructor: (@searchTypeText, @searchTypeFiltered) ->
        @._searchResult = Immutable.List()
        @._resultsCount = 0

        taiga.defineImmutableProperty @, "searchResult", () => return @._searchResult
        taiga.defineImmutableProperty @, "projectsCount", () => return @._resultsCount

    resetSearchResult: () ->
        @._resultsCount = 0
        @._searchResult = Immutable.List()

    fetchSearch: (params) ->
        params = angular.copy(params)
        searchType = params['result_type']
        delete params['result_type']

        if searchType == 'text'
            promise = @searchTypeText.getResults(params)
        else
            promise = @searchTypeFiltered.getResults(searchType, params)

        promise.then (items) =>
            @._resultsCount = items.size
            @._searchResult = items

angular.module("taigaSearch").service("tgSearchResultsService", SearchResultsService)
