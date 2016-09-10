# http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/frames.html#!AWS/S3.html

AWS = require 'aws-sdk'
config = require '../config.local'


s3 = new AWS.S3 config.s3

BUCKET = 'gitminer-hist'


# s3.createBucket Bucket: 'gitminer-hist', (err) ->
#   if err
#     console.error err
#     process.exit 1


  # params = {Bucket: 'gitminer-hist', Key: 'myKey', Body: 'Hello!'}
  # s3.putObject params, (err, data) ->
  #   console.log {err, data}


exports.uuid = ->
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
    r = Math.random() * 16 | 0
    v = if c is 'x' then r else (r & 0x3 | 0x8)
    return v.toString 16


exports.key = -> Math.round(Math.random() * 1e15).toString(36)


exports.put = (value, cb) ->
  key = exports.key()
  params = Bucket: BUCKET, Key: key, Body: JSON.stringify value
  s3.putObject params, (err, data) -> cb err, key


exports.get = (key, cb) ->
  params = Bucket: BUCKET, Key: key
  s3.getObject params, (err, data) ->
    if err then return cb err
    cb null, JSON.parse(data.Body.toString())


exports.delete = (key, cb) ->
  params = Bucket: BUCKET, Key: key
  s3.deleteObject params, cb
