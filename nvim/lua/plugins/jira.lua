return {
  "letieu/jira.nvim",
  opts = {
    jira = {
      limit = 200,
    },
    active_sprint_query = "project in ('Land Domain', 'Central Product Management') AND cf[10001] in (23192db5-6ebf-426f-8757-ef6d49ac5d92) AND (status in (Draft, Todo, 'In Progress', Rejected, Done) OR resolutiondate >= -7d) ORDER BY Flagged ASC, Rank ASC",
    queries = {
        ["My Tasks"] = "assignee = currentUser() AND statusCategory != Done ORDER BY RANK DESC",
        ["Backlog"] = "status = Draft ORDER BY Flagged ASC, RANK ASC",
    },
  },
}
