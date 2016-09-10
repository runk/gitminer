path = require 'path'
express = require 'express'
crypto = require 'crypto'
{domain, errorHandler} = require './lib/middleware/errorHandler'


devEnv = process.env.NODE_ENV is 'development'

app = express()

app.set 'views', path.join(__dirname, '/views')
app.set 'view engine', 'jade'
app.set 'view cache', !devEnv

app.use domain

# Routers
app.get '/', require './routes/index'

app.get '/parser.sh', require './routes/parser.sh'
app.use '/parser', require './routes/parser'
app.use '/report', require './routes/report'



app.use errorHandler {showStack: devEnv}


app.locals.gravatar = (email) ->
  md5 = crypto.createHash 'md5'
  md5.update (email.match(/<(.+)>/)?[1] ? email).toLowerCase()

  return """
    <img src="https://secure.gravatar.com/avatar/#{md5.digest 'hex'}?d=identicon&r=g" alt="" />
  """


# adityasabnis <aditya.sabnis@adslot.com>
app.locals.parseAuthor = (author) ->
  email: (author.match(/<(.+)>/)?[1] ? author).trim()
  name: (author.match(/(.+)</)?[1] ? author).trim()


app.locals.format = (number) -> String(number).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,")


port = 3000
app.listen port, (err) ->
  if err then return console.error err
  console.log "Listening on localhost:#{port}"
