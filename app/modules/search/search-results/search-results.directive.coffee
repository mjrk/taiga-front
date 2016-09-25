###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: search-results.directive.coffee
###

taiga = @.taiga

trim = @.taiga.trim
toString = @.taiga.toString
startswith = @.taiga.startswith


SearchResultsDirective = () ->
    link = (scope, element, attrs, ctrl) ->
        ctrl.fetch()

    return {
        controller: "SearchResults",
        controllerAs: "vm"
        link: link
    }

SearchResultsDirective.$inject = []

angular.module("taigaSearch").directive(
    "tgSearchResults", SearchResultsDirective
  )


SearchResultsTableDirective = ($compile) ->

    linkOrdering = ($scope, $el, $attrs, $ctrl) ->

        addOrderSvg = (target, order) ->
            icon = if startswith(order, "-") then "icon-arrow-up" else "icon-arrow-down"
            orderSvg = $compile("<tg-svg svg-icon='#{icon}'></tg-svg>")($scope)
            if not _.endsWith(target.html(), " ")
                target.append(" ")
            target.append(orderSvg)

        # Draw the arrow the first time
        currentOrder = $ctrl.getRouteParamsFilter("order_by") or "created_date"
        if currentOrder
            colHeadElement = $el.find(".row.title > div[data-fieldname='#{trim(currentOrder, "-")}']")
            addOrderSvg(colHeadElement, currentOrder)

        $el.on "click", ".row.title > div[data-fieldname]", (event) ->
            if $ctrl.loadingList
                return
            target = angular.element(event.currentTarget)

            currentOrder = $ctrl.getRouteParamsFilter("order_by")
            newOrder = target.data("fieldname")
            finalOrder = if currentOrder == newOrder then "-#{newOrder}" else newOrder

            $scope.$apply ->
                $ctrl.onChangeOrder(finalOrder).then ->
                    # Update the arrow
                    $el.find(".row.title > div > tg-svg").remove()
                    addOrderSvg(target, finalOrder)

    # getSearchResultController = (element) ->
    #     parent = element.parent()
    #     while parent?
    #         if parent.attr('tg-search-results')
    #             return parent.controller('tgSearchResults')
    #         parent = parent.parent()
    #     return null

    link = (scope, element, attrs) ->
        ctrl = element.controller('tgSearchResults')
        linkOrdering(scope, element, attrs, ctrl)

    return {
        link: link
    }

SearchResultsDirective.$inject = [
    "$compile"
]

angular.module("taigaSearch").directive(
    "tgSearchResultsTable", SearchResultsTableDirective
  )
