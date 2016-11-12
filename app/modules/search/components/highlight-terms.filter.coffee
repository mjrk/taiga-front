
module = angular.module("taigaSearch")


html5ToEntities = (value) ->
    value.replace(/[\u00A0-\u9999<>\&\'\"]/gim, (i) ->
        '&#' + i.charCodeAt(0) + ';'
    )


highlightTerms = ($sce) ->
    return (text, search, limit=150) ->
        if not text?.length > 0
            return ""

        text = html5ToEntities(text)
        if (!search)
            text
        else
            searchTerms = search.split(' ')
            searchTerms.sort (a, b) -> b.length - a.length

            for s in searchTerms
                regex = ///<span.*?<\/span>|(#{s})///ig
                text = text.replace(
                    regex, '<span class="search-match">$&</span>'
                )
            $sce.trustAsHtml(text)

module.filter("highlightTerms", ['$sce', highlightTerms])
