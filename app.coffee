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
    signout: require("#{modulePath}/api/user")().signout
    students: require("#{modulePath}/api/user")().all_students
    create_student: require("#{modulePath}/api/user")().create_student
    administrators: require("#{modulePath}/api/user")().all_admins
    editors: require("#{modulePath}/api/user")().all_editors
    create_administrator: require("#{modulePath}/api/user")().create_administrator
    create_editor: require("#{modulePath}/api/user")().create_editor
    get_career_by_id: require("#{modulePath}/api/career")().get_career_by_id
    get_courses_by_career: require("#{modulePath}/api/course")().get_courses_by_career
    get_points_institution: require("#{modulePath}/api/institution")().get_points_institution
    get_careers_by_departament: require("#{modulePath}/api/career")().get_careers_by_departament
    get_departaments_by_institution: require("#{modulePath}/api/departament")().get_departaments_by_institution
    set_points_institution: require("#{modulePath}/api/institution")().set_points_institution
    all_departaments: require("#{modulePath}/api/departament")().all_departaments
    all_institutions: require("#{modulePath}/api/institution")().all_institutions
    all_careers: require("#{modulePath}/api/career")().all_careers
    all_courses: require("#{modulePath}/api/course")().all_courses
    all_categories: require("#{modulePath}/api/category")().all_categories
    all_keywords: require("#{modulePath}/api/keyword")().all_keywords
    all_typematerials: require("#{modulePath}/api/typematerial")().all_typematerials
    all_mimetypes: require("#{modulePath}/api/mimetype")().all_mimetypes
    all_states: require("#{modulePath}/api/state")().all_states
    all_materials: require("#{modulePath}/api/material")().all_materials
    get_material_by_id: require("#{modulePath}/api/material")().get_material_by_id
    get_materials_by_course: require("#{modulePath}/api/material")().get_materials_by_course
    get_materials_by_name_or_description: require("#{modulePath}/api/material")().get_materials_by_name_or_description
    get_materials_by_category: require("#{modulePath}/api/material")().get_materials_by_category
    get_materials_by_keyword: require("#{modulePath}/api/material")().get_materials_by_keyword
    get_materials_by_typematerial: require("#{modulePath}/api/material")().get_materials_by_typematerial
    type_user: require("#{modulePath}/api/user")().type_user

#API
router.get '/api/institutions/all', ROUTES.api.all_institutions
router.get '/api/departaments/all', [], ROUTES.api.all_departaments
router.get '/api/courses/all', [], ROUTES.api.all_courses
router.get '/api/careers/all', [], ROUTES.api.all_careers
router.get '/api/mimetypes/all', [], ROUTES.api.all_mimetypes
router.get '/api/states/all', [], ROUTES.api.all_states
router.get '/api/categories/all', [], ROUTES.api.all_categories
router.get '/api/materials/all', [], ROUTES.api.all_materials
router.get '/api/keywords/all', [], ROUTES.api.all_keywords
router.get '/api/typematerials/all', [], ROUTES.api.all_typematerials
router.get '/api/users/all', [], ROUTES.api.users
router.get '/api/users/admin/all',[],ROUTES.api.administrators
router.get '/api/users/students/all', [], ROUTES.api.students
router.get '/api/users/editors/all', [], ROUTES.api.editors
router.get '/api/departaments/:ins_id', [], ROUTES.api.get_departaments_by_institution
router.get '/api/careers/:departament_id', [], ROUTES.api.get_careers_by_departament
router.get '/api/courses/:career_id', [], ROUTES.api.get_courses_by_career
router.get '/api/career/:career_id', [], ROUTES.api.get_career_by_id
router.get '/api/users/:user_id', [MIDDLEWARE.AUTH, MIDDLEWARE.USER_INFO], ROUTES.api.user_by_id
router.get '/api/users/:user_id/type', [], ROUTES.api.type_user
router.get '/api/materials/search', [], ROUTES.api.get_materials_by_name_or_description
router.get '/api/material/:material_id', [], ROUTES.api.get_material_by_id
router.get '/api/materials/:course_id', [], ROUTES.api.get_materials_by_course
router.get '/api/materials/category/:category_id', [], ROUTES.api.get_materials_by_category
router.get '/api/materials/keyword/:keyword_id', [], ROUTES.api.get_materials_by_keyword
router.get '/api/materials/typematerial/:typematerial_id', [], ROUTES.api.get_materials_by_typematerial

router.get '/api/institution/:ins_id/points', ROUTES.api.get_points_institution
router.post '/api/institutions/:ins_id/points/set', ROUTES.api.set_points_institution
router.post '/api/signin', [], ROUTES.api.signin
router.post '/api/signout', [], ROUTES.api.signout
router.post '/api/student/new', [], ROUTES.api.create_student
router.post '/api/administrator/new', [], ROUTES.api.create_administrator
router.post '/api/editor/new', [], ROUTES.api.create_editor
app.use '/', router
# App
app.listen 7070, -> console.log 'Backend running on port 7070! http://localhost:7070'