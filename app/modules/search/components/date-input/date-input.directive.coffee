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
# File: search.directive.coffee
###

SearchDateInputDirective = () ->

    # isDate = (date) ->
    #     new Date(date) != "Invalid Date" && !isNaN(new Date(date))

    link = (scope, el, attrs, ctrl) ->
        ctrl.resetDateValues(scope.vm.inputDateGte, scope.vm.inputDateLte)
        scope.$watch("vm.dateGte", (newValue, oldValue) ->
            if newValue == ""
                newValue = null
            ctrl.callback({dateGte: newValue})
        )
        scope.$watch("vm.dateLte", (newValue, oldValue) ->
            if newValue == ""
                newValue = null
            ctrl.callback({dateLte: newValue})
        )

    return {
        controller: "DateInput",
        controllerAs: "vm"
        templateUrl: 'search/components/date-input/' +
          'date-input.html',
        bindToController: true,
        scope: {
            inputDateGte: "=dateGte"
            inputDateLte: "=dateLte"
            onChange: "&"
        },
        link: link
    }

angular.module('taigaSearch').directive(
    'tgSearchDateInput', SearchDateInputDirective
)
