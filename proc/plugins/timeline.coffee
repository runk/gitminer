_ = require('lodash')

module.exports = (commits) ->
  result = {}
  authorsTotals = {}
  max = {}

  byMonth = _.groupBy commits, (commit) ->
    # return commit.date.toISOString().substring(0, 7) + '-01'
    if !commit.date then return '1975-01-01'
    return commit.date.substring(0, 7) + '-01'

  for date of byMonth
    byAuthor = _.groupBy(byMonth[date], 'author')

    for author of byAuthor
      stat = {files: 0, '+': 0, '-': 0}
      for commit in byAuthor[author]
        stat.files += commit.overall.files
        stat['+'] += commit.overall['+']
        stat['-'] += commit.overall['-']

       # Total will be used for sorting
      authorsTotals[author] = (authorsTotals[author] || 0) + stat['+'] + stat['-']

      result[date] = result[date] or {}
      result[date][author] = stat

      max[date] = Math.max(max[date] or 0, stat['+'] + stat['-'])

  authors = ({author, changes} for author, changes of authorsTotals)
  authors= authors
    .sort (a, b) -> return b.changes - a.changes
    .map (a) -> return a.author

  return {result, authors, max}
