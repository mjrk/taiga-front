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
# File: related-userstory-create-button.directive.coffee
###

module = angular.module('taigaEpics')

RelatedUserstoriesCreateButtonDirective = (@lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.showLightbox = () ->
            lightboxService.open(el.find(".lightbox-create-related-user-stories"))

        scope.closeLightbox = () ->
            scope.selectedUserstory = null
            lightboxService.close(el.find(".lightbox-create-related-user-stories"))

        scope.selectProject = () ->
            scope.selectedUserstory = null
            ctrl.selectProject(scope.selectedProject)

        scope.selectUserstory = () ->
            ctrl.selectUserstory(scope.selectedUserstory)

    return {
        link: link,
        templateUrl:"epics/related-userstories/related-userstories-create-button/related-userstories-create-button.html",
        controller: "RelatedUserstoriesCreateButtonCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
              showCreateRelatedUserstoriesLightbox: "=",
              project: "="
              epic: "="
              epicUserstories: "="
              loadRelatedUserstories:"&"
        }

    }

RelatedUserstoriesCreateButtonDirective.$inject = ["lightboxService",]

module.directive("tgRelatedUserstoriesCreateButton", RelatedUserstoriesCreateButtonDirective)
