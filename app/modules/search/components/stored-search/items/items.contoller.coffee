###
        '$tgStoredSearch',
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
taigaConfig = @.taigaConfig

generateHash = taiga.generateHash


class StoredSearchItemsController
    @.$inject = [
        '$tgStoredSearchProvider',
    ]

    constructor: (@storedSearch) ->
        @.items = @storedSearch.getStoredSearchItems()

    deleteItem: (name) ->
        @.items = @storedSearch.deleteStoredSearchItem(name)

    isEmpty: () ->
        Object.keys(@.items).length == 0

    staticSearchesEmpty: () ->
        @getStaticSeaches().length == 0

    getStaticSeaches: () ->
        taigaConfig.staticSearches or []


angular.module("taigaSearch").controller(
    "StoredSearchItems", StoredSearchItemsController
)
