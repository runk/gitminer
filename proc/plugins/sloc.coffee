
module.exports = (commits) ->
  map = {}
  for commit in commits when commit.date
    date = dateFloor commit.date, 2
    map[date] ?= {'+': 0, '-' : 0}
    map[date]['+'] += commit.overall['+']
    map[date]['-'] += commit.overall['-']

  return map


dateFloor = (date, days) ->
  wnd = days * 86400 * 1000
  time = new Date(date).getTime()
  time = Math.floor(time / wnd) * wnd
  return new Date(time).toISOString().substring(0, 10)
