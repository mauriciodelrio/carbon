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
  
  type_user: (req, res) ->
    User.connect (client) ->
      User.get_admin_by_id client, req.params.user_id, (response) ->
        if response.status is 'OK' and response?.data
          res.send status: 'OK', data: response.data
        else
          User.get_editor_by_id client, req.params.user_id, (response2) ->
            if response2.status is 'OK' and response2?.data
              res.send status: 'OK', data: response2.data
            else
              User.get_student_by_id client, req.params.user_id, (response3) ->
                if response3.status is 'OK' and response3?.data
                  res.send status: 'OK', data: response3.data
                else
                  res.send status:'ERROR', data: response3.data

  find_user: (req, res) ->
    if req.body?.email
      params =
        email : req.body.email
      User.connect (client) ->
        User.get_user_by_email client, params, (response) ->
          res.send status: 'OK', data: response

  change_state_user: (req, res) ->
    if req.body?.user_id and req.body.state?
      params =
        user_id : req.body.user_id
        state : req.body.state
      User.connect (client) ->
        User.change_state_user_by_id client, params, (response) ->
          res.send status: 'OK', data: response

  all_students: (req, res) ->
    User.connect (client) ->
      User.get_students client, (response) ->
        res.send status: 'OK', data: response

  all_admins: (req, res)->
    User.connect (client) ->
      User.get_admins client, (response) ->
        res.send status: 'OK', data: response
  
  all_editors: (req, res)->
    User.connect (client) ->
      User.get_editors client, (response) ->
        res.send status: 'OK', data: response

  user_id: (req, res) ->
    User.connect (client) ->
      User.get_user_by_id client, req.params.user_id, (response) ->
        res.send status: 'OK', data: response

  signin: (req, res) ->
    if req.body?.email and req.body?.password
      params =
        mail : req.body.email
        password : req.body.password
      User.connect (client) ->
        User.get_user_by_mail client, params, (user) ->
          if user[0]?.user_id
            #limpiar sesiones anteriores acá
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

  signout: (req, res) ->
    if req.session?.user_id
      console.log 'entro al if de signout'
      Cache.del "user:#{req.session.user_id}", () -> 
        Session.clear req, () ->
          console.log "redirect"
          res.send status: 'OK', data: null
    else 
      res.send status: 'OK', data: null

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
    if req.body and req.body.user_lastname? and req.body.user_name? and req.body.user_birthday? and req.body.user_email? and req.body.institution_id? and req.body.user_password? and req.body.user_gender?
      params = 
        lastname: _.get req, 'body.user_lastname', ''
        birthday: moment(_.get(req, 'body.user_birthday', '')).format("YYYY-MM-DD")
        email: _.get req, 'body.user_email', ''
        institution_id: _.get req, 'body.institution_id', ''
        name: _.get req, 'body.user_name', ''
        password: _.get req, 'body.user_password', ''
        gender: _.get req, 'body.user_gender', ''
      User.connect (client) ->
        User.create_student client, params, (response) ->
          if response.status is 'OK'
            res.send status: 'OK', data: response.data
          else
            res.sendStatus 500
    else
      res.sendStatus 500

  
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
