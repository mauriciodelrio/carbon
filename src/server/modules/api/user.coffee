User = new (require('../../lib/pgconn').User)()
Institution = new (require('../../lib/pgconn').Institution)()
Cache = new (require('../../lib/cache'))()
Session = new (require('../../lib/session'))()
_ = require 'lodash'
moment = require 'moment'
module.exports = () ->
  all_users: (req, res) ->
    User.connect (client) ->
      User.get_users client, (response) ->
        res.send status: 'OK', data: response
  
  all_students: (req, res) ->
    User.connect (client) ->
      User.get_students client, (response) ->
        res.send status: 'OK', data: response

  all_admins: (req, res)->
    User.connect (client) ->
        User.get_admins client, (response) ->
          res.send status: 'OK', data: response

  user_id: (req, res) ->
    User.connect (client) ->
      User.get_user_by_id client, req.params.user_id, (response) ->
        res.send status: 'OK', data: response

  signin: (req, res) ->
    console.log req.body
    if req.body?.email and req.body?.password
      params =
        mail : req.body.email
        password : req.body.password
      User.connect (client) ->
        User.get_user_by_mail client, params, (user) ->
          if user[0]?.user_id
            #limpiar sesiones anteriores acá
            console.log "user 0 0000 0 0 0 0 0 ", user[0]
            Session.set user[0].user_id, {}, req, true, (session_id) ->
              if session_id?
                User.clean_old_sessions_user client, user[0].user_id, session_id, (resp) ->
                  if resp.status is 'OK' and resp.data?
                    console.log resp
                  else
                    console.error resp
                Institution.connect (client) ->
                  Institution.get_points_in_institution client, '1', (points) ->
                    if points.status is 'OK' and points.data?
                      Institution.set_points_in_institution client, '1', points.data.sum, (resp_points) ->
                    else
                      console.error resp
                console.log "---- Seteo su session ----", session_id
                Cache.set "user:#{user.user_id}", user[0], (cache_user) ->
                  console.log "---- entro a Cache ----", cache_user
                  res.locals.USER = user[0]
                  User.count_sessions client, user[0].user_id, (result) ->
                    console.log "cantidad de sesiones", result
                  User.get_user_session client, session_id, user[0].user_id, (session) ->
                    res.send status: 'OK', data: {user: res.locals.USER, session: session}
              else
                console.error "EMPTY RESPONSE SESSION"
                res.send status: 'ERROR', data: "LOGIN ERROR"
          else
            console.error "aaaaaa", user
            res.send status: 'ERROR', data: "USER NOT FOUND"
    else
      console.error "LOGIN_ERROR"

  create_administrator: (req, res) ->
    console.log "req body admin", req.body
    params = 
      lastname: _.get req, 'body.lastname', 'name'
      birthday: _.get req, 'body.birthday', moment().format("YYYY-MM-DD")
      email: _.get req, 'body.email', 'sample@sample.cl'
      institution_id: _.get req, 'body.institution_id', '1'
      name: _.get req, 'body.name', 'name'
      password: _.get req, 'body.password', '1234'
      gender: _.get req, 'body.gender', 'other'
      contact_email: _.get req, 'body.contact_email', 'sample@sample.cl'
      contact_number: _.get req, 'body.contact_number', '+56912345678'
      cargo: _.get req, 'body.cargo', 'administrator'
    User.connect (client) ->
      User.create_administrator client, params, (response) ->
        res.send status: 'OK', data: response
  
  create_student: (req, res) ->
    console.log "req body student", req.body
    params = 
      lastname: _.get req, 'body.lastname', 'name'
      birthday: _.get req, 'body.birthday', moment().format("YYYY-MM-DD")
      email: _.get req, 'body.email', 'sample@sample.cl'
      institution_id: _.get req, 'body.institution_id', '1'
      name: _.get req, 'body.name', 'name'
      password: _.get req, 'body.password', '1234'
      gender: _.get req, 'body.gender', 'other'
    User.connect (client) ->
      User.create_student client, params, (response) ->
        res.send status: 'OK', data: response
  
  create_editor: (req, res) ->
    console.log "req body editor", req.body
    params = 
      lastname: _.get req, 'body.lastname', 'name'
      birthday: _.get req, 'body.birthday', moment().format("YYYY-MM-DD")
      email: _.get req, 'body.email', 'sample@sample.cl'
      institution_id: _.get req, 'body.institution_id', '1'
      name: _.get req, 'body.name', 'name'
      password: _.get req, 'body.password', '1234'
      gender: _.get req, 'body.gender', 'other'
      contact_email: _.get req, 'body.contact_email', 'sample@sample.cl'
      contact_number: _.get req, 'body.contact_number', '+56912345678'
      cargo: _.get req, 'body.cargo', 'editor'
    User.connect (client) ->
      User.create_editor client, params, (response) ->
        res.send status: 'OK', data: response
