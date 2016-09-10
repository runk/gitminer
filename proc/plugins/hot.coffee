
module.exports = (commits) ->
  map = {}
  for commit in commits
    for file of commit.files
      map[file] ?= {times: 0, lines: 0}
      map[file].times++
      map[file].lines += commit.files[file]['+'] + commit.files[file]['-']

  result = []
  for file of map
    result.push({file: file, times: map[file].times, lines: map[file].lines})

  result.sort (a, b) -> b.times - a.times
  return result.slice(0, 25)
