###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/epics/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
bindMethods = @.taiga.bindMethods

module = angular.module("taigaEpics")

#############################################################################
## Epic Detail Controller
#############################################################################

class EpicDetailController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "$log",
        "tgAppMetaService",
        "$tgAnalytics",
        "$tgNavUrls",
        "$translate",
        "$tgQueueModelTransformation",
        "tgErrorHandlingService"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appMetaService, @analytics, @navUrls, @translate, @modelTransform, @errorHandlingService) ->
        bindMethods(@)

        @scope.epicRef = @params.epicref
        @scope.sectionName = @translate.instant("EPIC.SECTION_NAME")
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @._setMeta()
            @.initializeOnDeleteGoToUrl()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    _setMeta: ->
        title = @translate.instant("EPIC.PAGE_TITLE", {
            epicRef: "##{@scope.epic.ref}"
            epicSubject: @scope.epic.subject
            projectName: @scope.project.name
        })
        description = @translate.instant("EPIC.PAGE_DESCRIPTION", {
            epicStatus: @scope.statusById[@scope.epic.status]?.name or "--"
            epicDescription: angular.element(@scope.epic.description_html or "").text()
        })
        @appMetaService.setAll(title, description)

    initializeEventHandlers: ->
        @scope.$on "attachment:create", =>
            @analytics.trackEvent("attachment", "create", "create attachment on epic", 1)

        @scope.$on "comment:new", =>
            @.loadEpic()

        @scope.$on "custom-attributes-values:edit", =>
            @rootscope.$broadcast("object:updated")

    initializeOnDeleteGoToUrl: ->
       ctx = {project: @scope.project.slug}
       @scope.onDeleteGoToUrl = @navUrls.resolve("project-epics", ctx)

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.projectId = project.id
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.statusList = project.epic_statuses
            @scope.statusById = groupBy(project.epic_statuses, (x) -> x.id)
            return project

    loadEpic: ->
        return @rs.epics.getByRef(@scope.projectId, @params.epicref).then (epic) =>
            @scope.epic = epic
            @scope.epicId = epic.id
            @scope.commentModel = epic

            @modelTransform.setObject(@scope, 'epic')

            if @scope.epic.neighbors.previous?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.epic.neighbors.previous.ref
                }
                @scope.previousUrl = @navUrls.resolve("project-epics-detail", ctx)

            if @scope.epic.neighbors.next?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.epic.neighbors.next.ref
                }
                @scope.nextUrl = @navUrls.resolve("project-epics-detail", ctx)

    loadInitialData: ->
        promise = @.loadProject()
        return promise.then (project) =>
            @.fillUsersAndRoles(project.members, project.roles)
            @.loadEpic()

    ###
    # Note: This methods (onUpvote() and onDownvote()) are related to tg-vote-button.
    #       See app/modules/components/vote-button for more info
    ###
    onUpvote: ->
        onSuccess = =>
            @.loadEpic()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.epics.upvote(@scope.epicId).then(onSuccess, onError)

    onDownvote: ->
        onSuccess = =>
            @.loadEpic()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.epics.downvote(@scope.epicId).then(onSuccess, onError)

    ###
    # Note: This methods (onWatch() and onUnwatch()) are related to tg-watch-button.
    #       See app/modules/components/watch-button for more info
    ###
    onWatch: ->
        onSuccess = =>
            @.loadEpic()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.epics.watch(@scope.epicId).then(onSuccess, onError)

    onUnwatch: ->
        onSuccess = =>
            @.loadEpic()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.epics.unwatch(@scope.epicId).then(onSuccess, onError)

module.controller("EpicDetailController", EpicDetailController)


#############################################################################
## Epic status display directive
#############################################################################

EpicStatusDisplayDirective = ($template, $compile) ->
    # Display if an epic is open or closed and its status.
    #
    # Example:
    #     tg-epic-status-display(ng-model="epic")
    #
    # Requirements:
    #   - Epic object (ng-model)
    #   - scope.statusById object

    template = $template.get("common/components/status-display.html", true)

    link = ($scope, $el, $attrs) ->
        render = (epic) ->
            status =  $scope.statusById[epic.status]

            html = template({
                is_closed: status.is_closed
                status: status
            })

            html = $compile(html)($scope)
            $el.html(html)

        $scope.$watch $attrs.ngModel, (epic) ->
            render(epic) if epic?

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgEpicStatusDisplay", ["$tgTemplate", "$compile", EpicStatusDisplayDirective])


#############################################################################
## Epic status button directive
#############################################################################

EpicStatusButtonDirective = ($rootScope, $repo, $confirm, $loading, $modelTransform, $compile, $translate, $template) ->
    # Display the status of epic and you can edit it.
    #
    # Example:
    #     tg-epic-status-button(ng-model="epic")
    #
    # Requirements:
    #   - Epic object (ng-model)
    #   - scope.statusById object
    #   - $scope.project.my_permissions

    template = $template.get("common/components/status-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_epic") != -1

        render = (epic) =>
            status = $scope.statusById[epic.status]

            html = $compile(template({
                status: status
                statuses: $scope.statusList
                editable: isEditable()
            }))($scope)

            $el.html(html)

        save = (status) ->
            currentLoading = $loading()
                .target($el)
                .start()

            transform = $modelTransform.save (epic) ->
                epic.status = status

                return epic

            onSuccess = ->
                $rootScope.$broadcast("object:updated")
                currentLoading.finish()

            onError = ->
                $confirm.notify("error")
                currentLoading.finish()

            transform.then(onSuccess, onError)

        $el.on "click", ".js-edit-status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            $el.find(".pop-status").popover().open()

        $el.on "click", ".status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            save(target.data("status-id"))

        $scope.$watch () ->
            return $model.$modelValue?.status
        , () ->
            epic = $model.$modelValue
            render(epic) if epic

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgEpicStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation",
                                        "$compile", "$translate", "$tgTemplate", EpicStatusButtonDirective])
