pg = require 'pg'
pg.defaults.poolSize = 200;
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

  get_editors: (client, cb) ->
    query = client.query 'SELECT * FROM public."Editor" as E', (err, res) ->
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

  get_student_by_id: (client, params, cb) -> #revisar esta funcion y queries
    query = client.query "SELECT * FROM public.\"Student\" as S WHERE S.user_id = '#{params}'", (err, res) ->
      if not err and res.rows.length > 0
        cb? {status: 'OK', data: {info: res.rows[0], type: 'student'}}
      else
        cb? {status: 'ERROR', data: err}

  get_editor_by_id: (client, params, cb) -> #revisar esta funcion y queries
    query = client.query "SELECT * FROM public.\"Editor\" as E WHERE E.user_id = '#{params}'", (err, res) ->
      if not err and res.rows.length > 0
        cb? {status: 'OK', data: {info: res.rows[0], type: 'editor'}}
      else
        cb? {status: 'ERROR', data: err}

  get_admin_by_id: (client, params, cb) -> #revisar esta funcion y queries
    query = client.query "SELECT * FROM public.\"Administrator\" as A WHERE A.user_id = '#{params}'", (err, res) ->
      if not err and res.rows.length > 0
        cb? {status: 'OK', data: {info: res.rows[0], type: 'administrator'}}
      else
        cb? {status: 'ERROR', data: err}

  get_user_by_mail: (client, params, cb) ->
    query = client.query "SELECT * FROM public.\"User\" as U INNER JOIN public.\"Institution\" as I ON U.institution_id = I.institution_id WHERE U.user_mail = '#{params.mail}' AND U.user_password = '#{params.password}'", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  change_state_user_by_id: (client, params, cb) ->
    query = client.query "UPDATE public.\"User\" SET user_state = #{params.state} WHERE user_id = '#{params.user_id}' RETURNING *", (err, res) ->
      if not err
        console.log "change stateeee"
        cb? {status: 'OK', data: res.rows[0]}
      else
        console.error err

  get_user_by_email: (client, params, cb) ->
    query = client.query "SELECT * FROM public.\"User\" as U INNER JOIN public.\"Institution\" as I ON U.institution_id = I.institution_id WHERE U.user_mail LIKE '%#{params.email}%'", (err, res) ->
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
    console.log("paramss student", params)
    query = client.query "INSERT INTO public.\"Student\" (user_lastname, user_birthday, user_mail, user_id, institution_id, user_state, student_files_uploaded, user_created_at, user_name, user_password, user_gender) VALUES ('#{params.lastname}', '#{params.birthday}', '#{params.email}', '#{id}', '#{params.institution_id}', #{true}, #{0}, '#{date_now}', '#{params.name}', '#{params.password}', '#{params.gender}') RETURNING *", (err, res) ->
      if not err
        cb? {status: 'OK', data: res.rows}
      else
        console.error err
        cb? {status: 'ERROR', data: err}

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
    query = client.query "SELECT * FROM public.\"Institution\" ORDER BY institution_points DESC ", (err, res) ->
      if not err
        cb? res.rows
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

class Career
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_careers: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Career\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err
  
  get_careers_by_departament: (client, params, cb) ->
    query = client.query "SELECT * FROM public.\"Career\" WHERE departament_id = '#{params}'", (err, res) ->
      if not err
        console.log "careers by depts", res.rows
        cb? {status: 'OK', data: res.rows}
      else
        console.error err
        cb? err
  
  get_career_by_id: (client, params, cb) ->
    query = client.query "SELECT * FROM public.\"Career\" WHERE career_id = '#{params}'", (err, res) ->
      if not err
        console.log "career", res.rows
        cb? {status: 'OK', data: res.rows[0]}
      else
        console.error err
        cb? err

class Departament
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_departaments: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Departament\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err
  
  get_departaments_by_institution: (client, params, cb) ->
    console.log "params de depppppp", params
    query = client.query "SELECT * FROM public.\"Departament\" WHERE institution_id = '#{params}'", (err, res) ->
      if not err
        console.log "depts by institution", res.rows
        cb? {status: 'OK', data: res.rows}
      else
        console.error err
        cb? err

class Course
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_courses: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Course\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  get_course_by_id: (client, params, cb) ->
    query = client.query "SELECT * FROM public.\"Course\" WHERE course_id = '#{params}'", (err, res) ->
      if not err
        console.log "course", res.rows
        cb? {status: 'OK', data: res.rows[0]}
      else
        console.error err
        cb? err
  
  get_courses_by_career: (client, params, cb) ->
    query = client.query "SELECT * FROM public.\"Course\" WHERE career_id = '#{params}'", (err, res) ->
      if not err
        console.log "course by career", res.rows
        cb? {status: 'OK', data: res.rows}
      else
        console.error err
        cb? err

class Category
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_categories: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Category\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  new_category: (client, params, cb) ->
    id = crypto.createHash('md5').update(this.hash()).digest 'hex'
    query = client.query "INSERT INTO public.\"Category\" (category_id, category_name) VALUES ('#{id}', '#{params}') RETURNING *", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

class Keyword
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_keywords: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Keyword\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err
  
  new_keyword: (client, params, cb) ->
    id = crypto.createHash('md5').update(this.hash()).digest 'hex'
    query = client.query "INSERT INTO public.\"Keyword\" (keyword_id, keyword_name) VALUES ('#{id}', '#{params}') RETURNING *", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

class Typematerial
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_typematerials: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Typematerial\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  new_typematerial: (client, params, cb) ->
    id = crypto.createHash('md5').update(this.hash()).digest 'hex'
    query = client.query "INSERT INTO public.\"Typematerial\" (typematerial_id, typematerial_name) VALUES ('#{id}', '#{params}') RETURNING *", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

class Mimetype #no añadiremos nada acá, solamente leeremos los tipos soportados
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_mimetypes: (client, cb) ->
    query = client.query "SELECT * FROM public.\"Mimetype\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

class State #no añadiremos nada acá, solamente leeremos los estados soportados
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_states: (client, cb) ->
    query = client.query "SELECT * FROM public.\"State\" ", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

class Material
  constructor: () ->

  connect: (cb) ->
    connectionString = process.env.DATABASE_URL or 'postgres://postgres:root@localhost:5432/carbon'
    client = new (pg.Client)(connectionString)
    client.connect()
    cb? client

  get_materials: (client, cb) ->
    get_material = "SELECT * FROM public.\"Material\" as M INNER JOIN public.\"Student\" as S ON M.student_id = S.user_id INNER JOIN public.\"Course\" as C ON M.course_id = C.course_id"
    joins_categories = "INNER JOIN public.\"Materialcategory\" as MC ON M.material_id = MC.material_id INNER JOIN public.\"Category\" as CAT ON MC.category_id = CAT.category_id"
    joins_typematerial = "INNER JOIN public.\"Materialtypematerial\" as MTM ON M.material_id = MTM.material_id INNER JOIN public.\"Typematerial\" as TM ON MTM.typematerial_id = TM.typematerial_id"
    joins_keywords = "INNER JOIN public.\"Materialkeyword\" as MK ON M.material_id = MK.material_id INNER JOIN public.\"Keyword\" as K ON MK.keyword_id = K.keyword_id"
    query = client.query "#{get_material} #{joins_categories} #{joins_typematerial} #{joins_keywords}",  (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err
  
  get_material_by_id: (client, id, cb) ->
    get_material = "SELECT * FROM public.\"Material\" as M INNER JOIN public.\"Student\" as S ON M.student_id = S.user_id INNER JOIN public.\"Course\" as C ON M.course_id = C.course_id"
    joins_categories = "INNER JOIN public.\"Materialcategory\" as MC ON M.material_id = MC.material_id INNER JOIN public.\"Category\" as CAT ON MC.category_id = CAT.category_id"
    joins_typematerial = "INNER JOIN public.\"Materialtypematerial\" as MTM ON M.material_id = MTM.material_id INNER JOIN public.\"Typematerial\" as TM ON MTM.typematerial_id = TM.typematerial_id"
    joins_keywords = "INNER JOIN public.\"Materialkeyword\" as MK ON M.material_id = MK.material_id INNER JOIN public.\"Keyword\" as K ON MK.keyword_id = K.keyword_id"
    query = client.query "#{get_material} #{joins_categories} #{joins_typematerial} #{joins_keywords} WHERE M.material_id = '#{id}'", (err, res) ->
      if not err
        cb? res.rows[0]
      else
        console.error err
        cb? err

  get_materials_by_course: (client, id, cb) ->
    get_material = "SELECT * FROM public.\"Material\" as M INNER JOIN public.\"Student\" as S ON M.student_id = S.user_id INNER JOIN public.\"Course\" as C ON M.course_id = C.course_id"
    joins_categories = "INNER JOIN public.\"Materialcategory\" as MC ON M.material_id = MC.material_id INNER JOIN public.\"Category\" as CAT ON MC.category_id = CAT.category_id"
    joins_typematerial = "INNER JOIN public.\"Materialtypematerial\" as MTM ON M.material_id = MTM.material_id INNER JOIN public.\"Typematerial\" as TM ON MTM.typematerial_id = TM.typematerial_id"
    joins_keywords = "INNER JOIN public.\"Materialkeyword\" as MK ON M.material_id = MK.material_id INNER JOIN public.\"Keyword\" as K ON MK.keyword_id = K.keyword_id"
    query = client.query "#{get_material} #{joins_categories} #{joins_typematerial} #{joins_keywords} WHERE M.course_id = '#{id}'", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  get_materials_by_name_or_description: (client, string, cb) ->
    get_material = "SELECT * FROM public.\"Material\" as M INNER JOIN public.\"Student\" as S ON M.student_id = S.user_id INNER JOIN public.\"Course\" as C ON M.course_id = C.course_id"
    joins_categories = "INNER JOIN public.\"Materialcategory\" as MC ON M.material_id = MC.material_id INNER JOIN public.\"Category\" as CAT ON MC.category_id = CAT.category_id"
    joins_typematerial = "INNER JOIN public.\"Materialtypematerial\" as MTM ON M.material_id = MTM.material_id INNER JOIN public.\"Typematerial\" as TM ON MTM.typematerial_id = TM.typematerial_id"
    joins_keywords = "INNER JOIN public.\"Materialkeyword\" as MK ON M.material_id = MK.material_id INNER JOIN public.\"Keyword\" as K ON MK.keyword_id = K.keyword_id"
    query = client.query "#{get_material} #{joins_categories} #{joins_typematerial} #{joins_keywords} WHERE M.name LIKE '%#{string}%' OR M.description LIKE '%#{string}%'", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  get_materials_by_category: (client, category_id, cb) ->
    get_material = "SELECT * FROM public.\"Material\" as M INNER JOIN public.\"Student\" as S ON M.student_id = S.user_id INNER JOIN public.\"Course\" as C ON M.course_id = C.course_id"
    joins_categories = "INNER JOIN public.\"Materialcategory\" as MC ON M.material_id = MC.material_id INNER JOIN public.\"Category\" as CAT ON MC.category_id = CAT.category_id"
    joins_typematerial = "INNER JOIN public.\"Materialtypematerial\" as MTM ON M.material_id = MTM.material_id INNER JOIN public.\"Typematerial\" as TM ON MTM.typematerial_id = TM.typematerial_id"
    joins_keywords = "INNER JOIN public.\"Materialkeyword\" as MK ON M.material_id = MK.material_id INNER JOIN public.\"Keyword\" as K ON MK.keyword_id = K.keyword_id"
    query = client.query "#{get_material} #{joins_categories} #{joins_typematerial} #{joins_keywords} WHERE MC.category_id = '#{category_id}'", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  get_materials_by_keyword: (client, keyword_id, cb) ->
    get_material = "SELECT * FROM public.\"Material\" as M INNER JOIN public.\"Student\" as S ON M.student_id = S.user_id INNER JOIN public.\"Course\" as C ON M.course_id = C.course_id"
    joins_categories = "INNER JOIN public.\"Materialcategory\" as MC ON M.material_id = MC.material_id INNER JOIN public.\"Category\" as CAT ON MC.category_id = CAT.category_id"
    joins_typematerial = "INNER JOIN public.\"Materialtypematerial\" as MTM ON M.material_id = MTM.material_id INNER JOIN public.\"Typematerial\" as TM ON MTM.typematerial_id = TM.typematerial_id"
    joins_keywords = "INNER JOIN public.\"Materialkeyword\" as MK ON M.material_id = MK.material_id INNER JOIN public.\"Keyword\" as K ON MK.keyword_id = K.keyword_id"
    query = client.query "#{get_material} #{joins_categories} #{joins_typematerial} #{joins_keywords} WHERE MK.keyword_id = '#{keyword_id}'", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

  get_materials_by_typematerial: (client, typematerial_id, cb) ->
    get_material = "SELECT * FROM public.\"Material\" as M INNER JOIN public.\"Student\" as S ON M.student_id = S.user_id INNER JOIN public.\"Course\" as C ON M.course_id = C.course_id"
    joins_categories = "INNER JOIN public.\"Materialcategory\" as MC ON M.material_id = MC.material_id INNER JOIN public.\"Category\" as CAT ON MC.category_id = CAT.category_id"
    joins_typematerial = "INNER JOIN public.\"Materialtypematerial\" as MTM ON M.material_id = MTM.material_id INNER JOIN public.\"Typematerial\" as TM ON MTM.typematerial_id = TM.typematerial_id"
    joins_keywords = "INNER JOIN public.\"Materialkeyword\" as MK ON M.material_id = MK.material_id INNER JOIN public.\"Keyword\" as K ON MK.keyword_id = K.keyword_id"
    query = client.query "#{get_material} #{joins_categories} #{joins_typematerial} #{joins_keywords} WHERE MTM.typematerial_id = '#{typematerial_id}'", (err, res) ->
      if not err
        cb? res.rows
      else
        console.error err
        cb? err

module.exports =
  User: User
  Institution: Institution
  Career: Career
  Course: Course
  Departament: Departament
  Category: Category
  Keyword: Keyword
  Typematerial: Typematerial
  Mimetype: Mimetype
  State: State
  Material: Material