fs = require 'fs'
domain = require 'domain'


exports.errorHandler = (options) ->

  options ?= {}
  showStack = options.showStack ? options.stack
  showMessage = options.showMessage ? options.message
  dumpExceptions = options.dumpExceptions ? options.dump
  {log} = options

  return (err, req, res, next) ->

    if log?
      logFn = log[err.logLevel] ? log.error
      logFn.call log, {err: err.nestedError ? err, req: req}, err.message

    # For client errors set status code to 400 else send a 500 server error code
    res.statusCode = err.statusCode ? 500

    if dumpExceptions then console.error err.stack
    accept = req.headers.accept ? ''
    if showStack
      if /html/.test accept
        fs.readFile "#{__dirname}/style.css", 'utf8', (e, style) ->
          fs.readFile "#{__dirname}/error.html", 'utf8', (e, html) ->
            stack = err.stack
            html = html
              .replace('{style}', style)
              .replace('{stack}', stack)
              .replace('{statusCode}', res.statusCode)
              .replace(/\{error\}/g, escape(err.toString()))
            res.setHeader 'Content-Type', 'text/html'
            res.end html
      else if /json/.test accept
        error = message: err.message, stack: err.stack
        error[prop] = err[prop] for prop, value of err
        res.setHeader 'Content-Type', 'application/json'
        res.end JSON.stringify {error}
      else
        res.setHeader 'Content-Type', 'text/plain'
        res.end err.stack
    else
      if /json/.test accept
        error = message: err.message
        error[prop] = err[prop] for prop, value of err when prop isnt 'stack'
        res.setHeader 'Content-Type', 'application/json'
        res.end JSON.stringify {error}
      else
        res.setHeader 'Content-Type', 'text/plain'
        res.end if showMessage then err.toString() else 'Internal Server Error'


# Wrap each request in domain, which makes handling unexpected errors much easier
exports.domain = (req, res, next) ->
  reqDomain = domain.create()
  reqDomain.on 'error', (err) ->
    # Passing err to our standard error handler
    next err

    # Though we've prevented abrupt process restarting, we are leaking
    # resources like crazy if this ever happens
    setTimeout (-> exports.die()), 10

  reqDomain.run next


exports.die = process.exit.bind process, 1


escape = (html) ->
  String(html)
    .replace(/&(?!\w+;)/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
