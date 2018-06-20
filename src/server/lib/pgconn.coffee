pg = require 'pg'
async = require 'async'
_ = require 'lodash'
moment = require 'moment'
crypto = require 'crypto'

class User
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_users: (client, cb) ->
    query = client.query 'SELECT * FROM public."User" as U', (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  get_students: (client, cb) ->
    query = client.query 'SELECT * FROM public."Student" as S', (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  get_admins: (client, cb) ->
    query = client.query 'SELECT * FROM public."Administrator" as A', (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  hash: (length = 32) ->
    charset = ''
    Array.apply(0, Array(length)).map( ->
      ((charset) -> charset.charAt Math.floor(Math.random() * charset.length)) 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    ).join ''

  crypt_pass: (pass) ->
    new_pass = crypto.createHash('md5').update(pass).digest 'hex'
    console.log "pass 1", new_pass
    new_pass2 = crypto.createHash('md5').update(pass).digest 'hex'
    console.log "pass 2",new_pass2
    console.log new_pass == new_pass2

  get_user_by_id: (client, params, cb) -> #revisar esta funcion y queries
    query = client.query "SELECT * FROM public.\"User\" as U INNER JOIN public.\"Institution\" AS I ON U.institution_id = I.institution_id WHERE U.user_id = '#{params}'", (err, res) ->
      if not err and res.rows.length > 0
        cb? res.rows
      else
        cb? err

  get_user_by_mail: (client, params, cb) ->
    query = client.query "SELECT * FROM public.\"User\" as U INNER JOIN public.\"Institution\" as I ON U.institution_id = I.institution_id WHERE U.user_mail = '#{params.mail}' AND U.user_password = '#{params.password}'", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err
  
  get_session_by_id: (client, params, cb) ->
    date_now = moment().format("YYYY-MM-DD HH:mm")
    query = client.query "SELECT * FROM public.\"User\" as U INNER JOIN public.\"Session\" as S ON U.user_id = S.user_id WHERE U.user_id = '#{params}' AND S.session_expired_at > '#{date_now}'", (err, res) ->
      if not err
        cb? res.rows[0]
      else
        console.error err
        cb? err

  create_student: (client, params, cb) ->
    date_now = moment().format("YYYY-MM-DD")
    id = crypto.createHash('md5').update(this.hash()).digest 'hex'
    query = client.query "INSERT INTO public.\"Student\" (user_lastname, user_birthday, user_mail, user_id, institution_id, user_state, student_files_uploaded, user_created_at, user_name, user_password, user_gender) VALUES ('#{params.lastname}', '#{params.birthday}', '#{params.email}', '#{id}', '#{params.institution_id}', #{true}, #{0}, '#{date_now}', '#{params.name}', '#{params.password}', '#{params.gender}') RETURNING *", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  create_administrator: (client, params, cb) ->
    date_now = moment().format("YYYY-MM-DD")
    id = crypto.createHash('md5').update(this.hash()).digest 'hex'
    query = client.query "INSERT INTO public.\"Administrator\" (administrator_contact_email, user_lastname, user_birthday, user_mail, user_id, administrator_contact_number, institution_id, user_state, user_created_at, user_name, user_password, user_gender, administrator_cargo) VALUES ('#{params.contact_email}', '#{params.lastname}', '#{params.birthday}', '#{params.email}', '#{id}', '#{params.contact_number}', '#{params.institution_id}', #{true}, '#{date_now}', '#{params.name}', '#{params.password}', '#{params.gender}', '#{params.cargo}') RETURNING *", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  create_editor: (client, params, cb) ->
    date_now = moment().format("YYYY-MM-DD")
    id = crypto.createHash('md5').update(this.hash()).digest 'hex'
    query = client.query "INSERT INTO public.\"Editor\" (editor_contact_email, user_lastname, user_birthday, user_mail, user_id, editor_contact_number, institution_id, user_state, user_created_at, user_name, user_password, user_gender, editor_cargo) VALUES ('#{params.contact_email}', '#{params.lastname}', '#{params.birthday}', '#{params.email}', '#{id}', '#{params.contact_number}', '#{params.institution_id}', #{true}, '#{date_now}', '#{params.name}', '#{params.password}', '#{params.gender}', '#{params.cargo}') RETURNING *", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err
  
  create_session: (client, params, cb) ->
    id = crypto.createHash('md5').update(this.hash()).digest 'hex'
    console.log typeof params
    date_created = moment().format("YYYY-MM-DD HH:mm")
    date_expired = moment().add(1, 'd').format("YYYY-MM-DD HH:mm")
    console.log "previo a la query de crear session", params
    query = client.query "INSERT INTO public.\"Session\" as S (user_id, session_id, session_created_at, session_expired_at, session_state) VALUES ('#{params}', '#{id}', '#{date_created}', '#{date_expired}', #{true}) RETURNING *", (err, res) ->
      if not err
        console.log "sessionnnn", res.rows
        cb? res.rows[0]
      else
        console.error err

  get_user_session: (client, session_id, user_id, cb) ->
    query = client.query "SELECT * FROM public.\"Session\" as S WHERE S.user_id = '#{user_id}' AND S.session_id = '#{session_id}'", (err, res) ->
      if not err
        cb? res.rows[0]
      else
        console.error err
        cb? err

  count_sessions: (client, user_id, cb) ->
    query = client.query "SELECT COUNT(user_id) FROM public.\"Session\" as S WHERE S.user_id = '#{user_id}'", (err, res) ->
      if not err
        cb? res.rows[0]
      else
        console.error err
        cb? err
  
  clean_old_sessions_user: (client, user_id, session_id, cb) ->
    query = client.query "UPDATE public.\"Session\" SET session_state = #{false} WHERE user_id = '#{user_id}' AND session_id != '#{session_id}' RETURNING *", (err, res) ->
      if not err
        console.log "not error clean sessions"
        cb? {status: 'OK', data: res.rows[0]}
      else
        console.error err
  clean_old_sessions: (client, user_id, cb) ->
    date_now = moment().format("YYYY-MM-DD HH:mm")
    query = client.query "UPDATE public.\"Session\" SET session_state = #{false} WHERE session_expired_at < '#{date_now}' RETURNING *", (err, res) ->
      if not err
        console.log "not error bdd"
        cb? {status: 'OK', data: res.rows[0]}
      else
        console.error err

class Institution
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  hash: (length = 32) ->
    charset = ''
    Array.apply(0, Array(length)).map( ->
      ((charset) -> charset.charAt Math.floor(Math.random() * charset.length)) 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    ).join ''

  get_institutions: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Institution\" ", (err, res) ->
      if not err
        cb? res.rows[0]
      else
        console.error err
        cb? err
  
  get_points_in_institution: (client, params, cb) ->
    query = client.query "SELECT SUM(student_files_uploaded) FROM public.\"Student\" WHERE institution_id = '#{params}'", (err, res) ->
      if not err
        console.log "points by institution", res.rows
        cb? {status: 'OK', data: res.rows[0]}
      else
        console.error err
        cb? err

  set_points_in_institution: (client, ins_id, points, cb) ->
    query = client.query "UPDATE public.\"Institution\" SET institution_points = #{points} WHERE institution_id = '#{ins_id}' RETURNING *", (err, res) ->
      if not err
        console.log "set points by institution", res.rows
        cb? {status: 'OK', data: res.rows[0]}
      else
        console.error err
        cb? err

module.exports =
  User: User
  Institution: Institution