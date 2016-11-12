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

hoursDelta = 60 * 60 * 1000
dateFields =
  hours_ago: (value) ->
      new Date(_.now() - parseInt(value) * hoursDelta).toString()
  days_ago: (value) ->
      new Date(_.now() - parseInt(value) * 24 * hoursDelta).toString()
  weeks_ago: (value) ->
      new Date(_.now() - parseInt(value) * 7 * 24 * hoursDelta).toString()
  end_of_day: (value) ->
      date = new Date(value)
      date.setHours(23)
      date.setMinutes(59)
      date.setSeconds(59)
      date.toString()
  in_hours: (value) ->
      new Date(_.now() + parseInt(value) * hoursDelta).toString()
  in_days: (value) ->
      new Date(_.now() + parseInt(value) * 24 * hoursDelta).toString()
  in_weeks: (value) ->
      new Date(_.now() + parseInt(value) * 7 * 24 * hoursDelta).toString()


transformToApi = (field, value) ->
    if value?.length
        for key, transform of dateFields
            if _.startsWith(value, key)
                transformed_value = value.replace(///^#{key}///, "")
                transformed_value = transform(transformed_value)
                if Number.isNaN(transformed_value)
                    # TODO raise, catch and show error for exception
                    console.log("#{value} is not a number")
                    return null
                return transformed_value
    value


class SearchTypeFiltered extends taiga.Service
    @.$inject = [
          "tgResources"
          "$tgSprintsResourcesProvider"
    ]

    constructor: (@rs, @sprintsProvider) ->
        @sprintsProvider(@rs)

    getResults: (type, client_params) ->
        params = {}
        for k, v of client_params
            if v?.length
                params[k] = transformToApi(k, v)
            else
                params[k] = v

        @rs[type].listInAllProjects(params).then (result) ->
            if result.toJS?
                result = result.toJS()
            else
                result = (i.getAttrs() for i in result)

            # for item in result
            #     item.type = type
            # Immutable.fromJS(result)
            result

angular.module("taigaSearch").service("SearchTypeFiltered", SearchTypeFiltered)
