import {
  for_each = local.repos
  to = github_repository.repos[each.value.name]
  id = each.value.name
}

