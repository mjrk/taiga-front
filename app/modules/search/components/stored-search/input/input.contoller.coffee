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

taiga = @.taiga

generateHash = taiga.generateHash


class StoredSearchInputController

    @.$inject = [
        '$tgStoredSearchProvider',
        '$routeParams',
        '$tgNavUrls',
        '$httpParamSerializer',
        "$location"
    ]

    constructor: (
        @storedSearch, @routeParams, @navUrls, @paramSerializer, @location
    ) ->
        @.initialParams = angular.copy(@routeParams)
        @.storedSearchName = @routeParams.storedSearchName or ""
        @.justSaved = false

    saveStoredSearchItem: () ->
        @routeParams.storedSearchName = @.storedSearchName
        @storedSearch.updateStoredSearchItem(@.storedSearchName, =>
            @generateUrl(updateLocation=true)
        )
        @.justSaved = true

    generateUrl: (updateLocation=false) ->
        result_type = @routeParams["result_type"] or "text"
        url = @navUrls.resolve("search-results", result_type: result_type)

        params = _.omit(@routeParams, "result_type")
        if updateLocation
            @location.search(params)
        url + "?" + @paramSerializer(params)

    storedSearchItemExists: () ->
        @storedSearch.getStoredSearchItem(@.storedSearchName)?

    storedSearchUnmodified: () ->
        @storedSearch.getStoredSearchItem(@.storedSearchName) == @generateUrl()

angular.module("taigaSearch").controller(
    "StoredSearchInput", StoredSearchInputController
)
