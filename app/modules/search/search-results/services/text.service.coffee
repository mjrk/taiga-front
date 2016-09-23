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

class SearchTypeText extends taiga.Service
    @.$inject = [
          "TEXT_SEARCH_CONFIG"
          "tgResources"
          "tgProjectsService"
          "$tgResources"
          "$q"
    ]

    constructor: (@config, @rs, @projectsService, @projectsResources, @q) ->
        @.decorate = @projectsService._decorate.bind(@projectsService)

    getResults: (params) ->
        params = angular.copy(params)
        _.assign(params, @getFilter(params.filter))

        return @_fetchOptionalSearches(params).then (projects) =>
            if params.q
                projects = (
                    p for p in projects when p['matchCount'] > 0
                )
            projects.sort (a, b) -> b['matchCount'] - a['matchCount']
            projects = Immutable.fromJS(projects)
            projects = projects.map(@.decorate)
            projects

    getFilter: (filter) ->
        if filter == 'people'
            return {is_looking_for_people: true}
        else if filter == 'scrum'
            return {is_backlog_activated: true}
        else if filter == 'kanban'
            return {is_kanban_activated: true}

        return {}

    _fetchOptionalSearches: (params) ->
        term = params.q
        projectParams = _.extend({}, params)
        delete projectParams.q

        @rs.projects.getAllProjects(projectParams).then (result) =>
            projects = result.data
            if term?.length > 0
                promises = (@_updateProject(p, params) for p in projects)
                @q.all(promises).then (results) ->
                    projects
            else
                projects

    _updateProject: (project, params) ->
        term = params.q
        project.matchCount = @_getMatchCount(
            project, @.config.projects.fields, term
        )

        @projectsResources.search.do(project.id, term).then (result) =>
            for k, v of result
                project[k] = v
                for entry in v
                    fields = @.config[k]?.fields
                    if fields?.length > 0
                        project.matchCount += @_getMatchCount(
                            entry, fields, term
                        )
            result

    _getMatchCount: (instance, fields, search) ->
        searchTerms = search.split(' ')
        count = 0
        for field in fields
            for term in searchTerms
                if _.isArray(instance[field])
                    for entry in instance[field]
                        if @_matches(entry, term)
                            count++
                else if instance[field]?.length > 0
                    if @_matches(instance[field], term)
                        count++
        count

    _matches: (text, term) ->
        _.includes(text.toLowerCase(), term.toLowerCase())

angular.module("taigaSearch").service("SearchTypeText", SearchTypeText)
