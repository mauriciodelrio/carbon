# Libs
express = require 'express'
app = express()
CONFIG = require('./config').CONFIG
router = require('express').Router()
session = require 'express-session'
bodyParser = require 'body-parser'
RedisStore = require('connect-redis') session
config = require 'config'
cors = require './src/server/middleware/cors'
app.use express.json()
app.use bodyParser.urlencoded extended: false
app.all '*' , cors #TODO: REMOVE CORS ALL
app.use session {
  store: new RedisStore url: CONFIG?.DB?.REDIS?.URL
  prefix: CONFIG?.DB?.REDIS?.PREFIX + 'sess:'
  key: CONFIG.EXPRESS.SESSION.KEY
  secret: CONFIG.EXPRESS.SESSION.SECRET
  resave: true,
  saveUninitialized: true
}
# Middleware
middlewarePath = './src/server/middleware'
MIDDLEWARE =
  AUTH: require "#{middlewarePath}/auth"
  USER_INFO: require "#{middlewarePath}/user_info"

# Routing
modulePath = './src/server/modules'
ROUTES =
  api:
    users: require("#{modulePath}/api/user")().all_users
    user_by_id: require("#{modulePath}/api/user")().user_id
    signin: require("#{modulePath}/api/user")().signin
    students: require("#{modulePath}/api/user")().all_students
    create_student: require("#{modulePath}/api/user")().create_student
    administrators: require("#{modulePath}/api/user")().all_admins
    create_administrator: require("#{modulePath}/api/user")().create_administrator
    create_editor: require("#{modulePath}/api/user")().create_editor
    all_institutions: require("#{modulePath}/api/institution")().all_institutions
    get_points_institution: require("#{modulePath}/api/institution")().get_points_institution
    set_points_institution: require("#{modulePath}/api/institution")().set_points_institution

#API
router.get '/users/all', [], ROUTES.api.users
router.get '/users/students/all', [], ROUTES.api.students
router.get '/users/admin/all',[],ROUTES.api.administrators
router.get '/api/users/:user_id', [MIDDLEWARE.AUTH, MIDDLEWARE.USER_INFO], ROUTES.api.user_by_id
router.get '/api/institutions/all', ROUTES.api.all_institutions
router.get '/api/institution/:ins_id/points', ROUTES.api.get_points_institution
router.post '/api/institutions/:ins_id/points/set', ROUTES.api.set_points_institution
router.post '/api/signin', [], ROUTES.api.signin
router.post '/api/student/new', [], ROUTES.api.create_student
router.post '/api/administrator/new', [], ROUTES.api.create_administrator
router.post '/api/editor/new', [], ROUTES.api.create_editor
app.use '/', router
# App
app.listen 7070, -> console.log 'Backend running on port 7070! http://localhost:7070'