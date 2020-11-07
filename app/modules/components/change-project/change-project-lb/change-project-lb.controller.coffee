###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/change-project/change-project-lb/change-project-lb.controller.coffee
###

module = angular.module("taigaComponents")

class ChangeProjectLightboxController
    @.$inject = [
        'tgProjectService'
        '$tgResources'
        '$tgRepo'
        '$tgNavUrls'
        '$tgLocation'
        'lightboxService'
        '$window'
    ]

    constructor: (
        @projectService
        @rs
        @repo
        @navUrls
        @location
        @lightboxService
        @window
    ) ->
        @.projectId = @projectService.project.get('id')
        @.loading = false
        @.selectedProjectId = null
        @._loadProjects()

    _loadProjects: () ->
        if @._isIssue()
            @._loadProjectsForIssue()
        else if @._isUs()
            @._loadProjectsForUs()
        else
            @.projects = []

    _isIssue: () ->
        @.item._name == 'issues'

    _isUs: () ->
        @.item._name == 'userstories'

    _loadProjectsForIssue: () ->
        @rs.projects.list().then (projects) =>
            @.projects = _.filter(
                projects, (p) =>
                    p.id != @.projectId and
                    p.is_issues_activated and
                    p.my_permissions.indexOf("add_issue") != -1 and
                    not p.blocked_code
            )

    _loadProjectsForUs: () ->
        @rs.projects.list().then (projects) =>
            @.projects = _.filter(
                projects, (p) =>
                    p.id != @.projectId and
                    (
                        p.is_kanban_activated or
                        p.is_backlog_activated
                    ) and
                    p.my_permissions.indexOf("add_us") != -1 and
                    not p.blocked_code
            )

    _prepareItem: () ->
        # set the attributes so they appear in _modifiedAttrs:
        #
        # The current backend implementation matches these fields by their
        # name and slug to the new project. It is not possible to provide
        # IDs of the corresponding models in the new project, the backend
        # resets the entities not found in the existing project to default ones
        # in the new project.
        @.item.setAttr('status', @.item.status)

        if @._isIssue()
            @.item.setAttr('milestone', @.item.milestone)
            @.item.setAttr('status', @.item.status)
            @.item.setAttr('priority', @.item.priority)
            @.item.setAttr('severity', @.item.severity)
            @.item.setAttr('type', @.item.type)
        else if @._isUs()
            @.item.setAttr('status', @.item.status)

    submit: () ->
        @.item.project = @.selectedProjectId
        @._prepareItem()

        # alternatively, @repo.save(@.item, false) can be used:
        # with patch=false, all values are send on save.
        @repo.save(@.item).then (data) =>
            detailPage = "project-#{@.item._name}-detail"
            ctx = {
                project: data.project_extra_info.slug
                ref: data.ref
            }
            newUrl = @navUrls.resolve(detailPage, ctx)

            # FIXME Although we reload the page fully, exceptions for all 5
            # fields are thrown:
            # Error: status is undefined
            # TODO update item and services without reloading the page
            @window.location.href = newUrl

module.controller("ChangeProjectLbCtrl", ChangeProjectLightboxController)
