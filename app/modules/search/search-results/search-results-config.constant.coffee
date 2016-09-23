

TEXT_SEARCH_CONFIG =
    search_in: ["projects", "userstories", "tasks", "issues", "wikipages"]
    projects:
        fields: ["name", "tags", "description"]
    userstories:
        fields: ["ref", "subject", "description"]
    issues:
        fields: ["ref", "subject", "description"]
    tasks:
        fields: ["ref", "subject", "description"]
    wikipages:
        fields: ["slug", "content"]


angular.module("taigaSearch").constant("TEXT_SEARCH_CONFIG", TEXT_SEARCH_CONFIG)
