

class TimeSpentController
    @.$inject = [
        "$rootScope",
        "$tgConfirm",
        "$tgQueueModelTransformation",
        "$window"
        "$interval"
    ]

    constructor: (@rootScope, @confirm, @modelTransform, @window, @interval) ->
        @.editMode = false
        @.loadingTimeSpent = false
        @._updateFormattedTime()

    _updateFormattedTime: (timeSpent) ->
        if not timeSpent
            timeSpent = @.item.total_time_spent

        hours = (timeSpent / 60);
        full_hours = Math.floor(hours);
        full_minutes = timeSpent - full_hours*60
        if full_hours < 10
            '0' + full_hours

        @.formattedTime = "#{full_hours}:#{('0'+full_minutes).slice(-2)}"

    _updateTimeSpentToDate: () ->
        if @.formattedTime
            try
                splittime = @.formattedTime.split(':')
                if splittime.length == 2
                    minutes = parseInt(splittime[1])
                    minutes += parseInt(splittime[0]) * 60
                else if splittime.length == 1
                    minutes = parseInt(splittime[0])
                else
                    @confirm.notify('Wrong format')
                    return false

                @.item.time_spent_to_date = minutes
                return true

            catch e
                @confirm.notify('Wrong format: ' + e)
                return false

    timeIsRunning: () ->
        running = @.item.time_spent_status == "in_progress"
        if running and not @.startCounter and not @.activeInterval
            @.startCounter = new Date()
            @.activeInterval = @interval( () =>
                now = new Date()
                diffMs = (now - @.startCounter);
                diffMins = Math.floor(diffMs / 60000);
                total_time_spent = @.item.total_time_spent + diffMins
                @._updateFormattedTime(total_time_spent)
            , 60000)
        else if not running and @.activeInterval
            @interval.cancel(@.activeInterval)
            @.activeInterval = null
            @.startCounter = null

        return running

    showTimeSpent: () ->
        return @.item?.time_spent_to_date?

    _checkPermissions: () ->
        @.permissions = {
            canEdit: _.includes(@.project.my_permissions, @.requiredPerm) and @.project.i_am_admin,
        }

    cancelEdit: () ->
        @.editMode = false
        @._updateFormattedTime()

    editTimeSpent: (value) ->
        selection = @window.getSelection()
        if selection.type != "Range"
            if value
                @.editMode = true
            if !value
                @.editMode = false

    onKeyDown: (event) ->
        if event.which == 13
            @.saveTimeSpent()

        if event.which == 27
            @._updateFormattedTime()
            @.editTimeSpent(false)

    saveTimeSpent: () ->
        if not @._updateTimeSpentToDate()
            return false

        onEditTimeSpentSuccess = () =>
            @.loadingTimeSpent = false
            @rootScope.$broadcast("object:updated")
            @confirm.notify('success')
            @._updateFormattedTime(@.item.time_spent_to_date)

        onEditTimeSpentError = (response) =>
            @.loadingTimeSpent = false
            if response._error_message
                @confirm.notify('error', response._error_message)
            else
                @confirm.notify('error')
            @._updateFormattedTime()

        @.editMode = false
        @.loadingTimeSpent = true
        item = @.item

        transform = @modelTransform.save (item) =>
            return item
        return transform.then(onEditTimeSpentSuccess, onEditTimeSpentError)

    color: () ->
        if @.timeIsRunning()
            return "red"
        else
            return "gray"


angular.module('taigaComponents').controller('TimeSpentCtrl', TimeSpentController)
