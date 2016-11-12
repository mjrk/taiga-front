
taiga = @.taiga

generateHash = taiga.generateHash

storedSearchProvider = ($storage) ->
    service =
        getStoredSearchItems: () ->
            $storage.get("searchStoredSearchItems") or {}

        setStoredSearchItems: (items) ->
            $storage.set("searchStoredSearchItems", items)

        getStoredSearchItem: (name) ->
            @getStoredSearchItems()[name]

        updateStoredSearchItem: (name, callback) ->
            items = @getStoredSearchItems()
            items[name] = callback(items[name])
            @setStoredSearchItems(items)
            items

        deleteStoredSearchItem: (name) ->
            items = @getStoredSearchItems()
            delete items[name]
            @setStoredSearchItems(items)
            items
    service

module = angular.module("taigaSearch")
module.factory("$tgStoredSearchProvider", [
    "$tgStorage", storedSearchProvider
])
