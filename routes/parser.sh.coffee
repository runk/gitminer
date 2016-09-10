fs = require 'fs'


module.exports = (req, res, next) ->
  parsersh = fs.readFileSync("#{__dirname}/../public/parser.sh", 'utf8')

  res.set 'Content-Type': 'plain/text'
  res.send parsersh

