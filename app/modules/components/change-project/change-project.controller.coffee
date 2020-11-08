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
# File: components/change-project/change-project-controller.coffee
###

taiga = @.taiga

class ChangeProjectController
    @.$inject = [
        "$translate"
        "tgLightboxFactory"
        "tgProjectService"
        "$rootScope"
    ]

    constructor: (@translate, @tgLightboxFactory, @projectService,  @rootscope) ->
        @.disabled = false

    changeProject: () ->
        if @.disabled is not true
            @tgLightboxFactory.create(
                "tg-change-project-lb",
                {
                    "class": "lightbox lightbox-change-project"
                    "item": "item"
                },
                {
                    "item": @.item
                }
            )

angular.module('taigaComponents').controller('ChangeProjectCtrl', ChangeProjectController)
