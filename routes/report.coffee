fs = require 'fs'

{Router} = require 'express'
proc = require '../proc'
storage = require '../lib/storage'

module.exports = r = Router()

cache = {}

getCommitsMw = (req, res, next) ->
  {uuid} = req.params

  if uuid of cache
    console.log 'doing fast'
    req.commits = cache[uuid].commits
    return next()

  console.log 'doing slow'
  # f = (cb) ->
    # cb null, JSON.parse fs.readFileSync './test.json'

  # f (err, data) ->
  storage.get uuid, (err, data) ->
    if err
      if err.code is 'NoSuchKey' then return res.sendStatus 404
      return next err

    # fs.writeFileSync './test.json', JSON.stringify(data)
    cache[uuid] = data
    req.commits = data.commits
    next()


r.get '/:uuid', getCommitsMw, (req, res, next) ->
  context = proc.context(req.commits)
  context.uuid = req.params.uuid
  res.render 'report', context


r.get '/delete/:uuid', (req, res, next) ->
  {uuid} = req.params
  storage.delete uuid, (err, foo) ->
    console.log foo
    if err then return next err
    delete cache[uuid]
    res.send "Deleted: '#{uuid}'"
