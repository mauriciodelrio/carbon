Course = new (require('../../lib/pgconn').Course)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_courses: (req, res) ->
    Course.connect (client) ->
      Course.get_courses client, (courses) ->
        client.end()
        res.send status: 'OK', data: courses

  get_courses_by_career: (req, res) ->
    Course.connect (client) ->
      Course.get_courses_by_career client, req.params.career_id, (courses) ->
        client.end()
        res.send status: 'OK', data: courses
  
  get_course_by_id: (req, res) ->
    Course.connect (client) ->
      Course.get_course_by_id client, req.params.course_id, (course) ->
        client.end()
        res.send status: 'OK', data: course
