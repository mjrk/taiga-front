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
# File: related-userstory-row.controller.coffee
###

module = angular.module("taigaEpics")

class RelatedUserstoriesCreateButtonController
    @.$inject = [
        "tgCurrentUserService",
        "tgResources",
        "$tgConfirm",
        "$tgAnalytics"
    ]

    constructor: (@currentUserService, @rs, @confirm, @analytics) ->
        @.projects = @currentUserService.projects.get("all")
        @.projectUserstories = Immutable.List()
        @.selectedUserstoryId = null
        @.loading = false

    selectProject: (selectedProjectId, onSelectedProject) ->
        @rs.userstories.listAllInProject(selectedProjectId).then (data) =>
            excludeIds = @.epicUserstories.map((us) -> us.get('id'))
            filteredData = data.filter((us) -> excludeIds.indexOf(us.get('id')) == -1)
            @.projectUserstories = filteredData
            if onSelectedProject
                onSelectedProject()

    selectUserstory: (selectedUserstoryId) ->
        @.selectedUserstoryId = selectedUserstoryId

    saveRelatedUserStory: (onSavedRelatedUserstory) ->
        # TODO: validate form
        @.loading = true

        onError = () =>
            @.loading = false
            @confirm.notify("error")

        onSuccess = () =>
            @analytics.trackEvent("epic related user story", "create", "create related user story on epic", 1)
            @.loading = false
            if onSavedRelatedUserstory
                onSavedRelatedUserstory()
            @.loadRelatedUserstories()

        epicId = @.epic.get('id')
        @rs.epics.addRelatedUserstory(epicId, @.selectedUserstoryId).then(onSuccess, onError)


module.controller("RelatedUserstoriesCreateButtonCtrl", RelatedUserstoriesCreateButtonController)
