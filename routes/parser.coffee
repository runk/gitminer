fs = require 'fs'

{Router} = require 'express'
bodyParser = require 'body-parser'
proc = require '../proc'
storage = require '../lib/storage'


module.exports = r = Router()

r.use bodyParser.raw limit: '10mb'


r.put '/do', (req, res, next) ->
  # console.log req.body.toString(), req.headers

  data =
    commits: proc.parseLog '\n' + req.body.toString()
    version: 1

  storage.put data, (err, uuid) ->
    if err then return next err

    res.set 'Content-Type', 'test/plain'
    res.send "Result can be found on \nhttps://gitminer.com/report/#{uuid}\n"
