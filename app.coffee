# Libs
express = require 'express'
app = express()
router = require('express').Router()
session = require 'express-session'
bodyParser = require 'body-parser'
RedisStore = require('connect-redis') session
config = require 'config'

app.use express.json()
app.use bodyParser.urlencoded extended: false

# Middleware
middlewarePath = './src/server/middleware'
MIDDLEWARE =
  IS_AUTH: require "#{middlewarePath}/is-auth"

# Routing
modulePath = './src/server/modules'

ROUTES =
  api:
    hola_mundo: require("#{modulePath}/api/hola_mundo")().index
    users: require("#{modulePath}/api/users")().index
#API
router.get '/teams', [], ROUTES.api.hola_mundo
router.get '/users/all', [], ROUTES.api.users
app.use '/', router
# App
app.listen 7070, -> console.log 'Backend running on port 7070! http://localhost:7070'