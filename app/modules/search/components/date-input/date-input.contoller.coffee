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


class DateInputController
    @.$inject = [
        '$timeout'
    ]

    constructor: (@timeout) ->
        @.fromFormats =
          from: "From"
          hours_ago: "hours ago"
          days_ago: "days ago"
          weeks_ago: "weeks ago"
          months_ago: "months ago"
          years_ago: "years ago"
        @.selectedFromFormat = "from"
        @.timeDeltaFrom = null

        @.toFormats =
          end_of_day: "Until"
          before: "Before"
          in_hours: "in hours"
          in_days: "in months"
          in_weeks: "in years"
        @.selectedToFormat = "end_of_day"
        @.timeDeltaTo = null

    selectFromFormat: (fromFormat) ->
        previousFormat = @.selectedFromFormat
        @.selectedFromFormat = fromFormat
        if (
            !@isDateFormat(previousFormat) and !@isDateFormat(fromFormat) and
            @.timeDeltaFrom?
        )
            @submitTimeDelta()
        else if @isDateFormat(previousFormat)
            @.timeDeltaFrom = null
        else if @isDateFormat(fromFormat)
            @.dateGte = ""

    selectToFormat: (toFormat) ->
        previousFormat = @.selectedToFormat
        @.selectedToFormat = toFormat
        if (
            !@isDateFormat(previousFormat) and !@isDateFormat(toFormat) and
            @.timeDeltaTo?
        )
            @submitTimeDelta()
        else if (
            @isDateFormat(previousFormat) and @isDateFormat(toFormat)
        )
            @callback({})
        else if @isDateFormat(previousFormat)
            @.timeDeltaTo = null
        else if @isDateFormat(toFormat)
            @.dateLte = ""

    # submitDateInput: (keyEvent) ->
    #     if keyEvent.which == 13
    #         @submitTimeDelta()

    submitTimeDelta: () ->
        @timeout =>
            dateGte = @.dateGte
            if not @isDateFormat(@.selectedFromFormat)
                dateGte = @.selectedFromFormat + (@.timeDeltaFrom or 0)

            dateLte = @.dateLte
            if not @isDateFormat(@.selectedToFormat)
                dateLte = @.selectedToFormat + (@.timeDeltaTo or 0)

            @.dateGte = dateGte
            @.dateLte = dateLte

    resetDateValues: (dateGte="", dateLte="") ->
        @.dateGte = dateGte
        for k, v of @.fromFormats
            if dateGte.startsWith(k)
                @.selectedFromFormat = k
                @.timeDeltaFrom = parseInt(dateGte.replace(///^#{k}///, ""))
                break

        if dateLte.startsWith("end_of_day")
          @.selectedToFormat = "end_of_day"
          @.dateLte = dateLte.replace(/^end_of_day/, "")
        else if dateLte.startsWith("before")
          @.selectedToFormat = "before"
          @.dateLte = dateLte.replace(/^before/, "")
        else
          @.dateLte = dateLte
          for k, v of @.toFormats
              if dateLte.startsWith(k)
                  @.selectedToFormat = k
                  @.timeDeltaTo = parseInt(dateLte.replace(///^#{k}///, ""))
                  break

    callback: (params) ->
        onChange = @.onChange()
        if onChange?
            if not params.hasOwnProperty("dateGte")
                params["dateGte"] = @.dateGte
            if not params.hasOwnProperty("dateLte")
                params["dateLte"] = @.dateLte
            if (
                @.selectedToFormat == "end_of_day" and
                params.dateLte?.length and
                not params.dateLte.startsWith("end_of_day")
            )
                params = angular.copy(params)
                params.dateLte = "end_of_day" + params.dateLte
            onChange(params)

    isDateFormat: (format) ->
        ["from", "before", "end_of_day"].indexOf(format) != -1

angular.module("taigaSearch").controller("DateInput", DateInputController)
