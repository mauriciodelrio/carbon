Material = new (require('../../lib/pgconn').Material)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_materials: (req, res) ->
    Material.connect (client) ->
      Material.get_materials client, (materials) ->
        client.end()
        res.send status: 'OK', data: materials

  get_material_by_id: (req, res) ->
    Material.connect (client) ->
      Material.get_material_by_id client, req.params.material_id, (material) ->
        client.end()
        res.send status: 'OK', data: material
  
  get_materials_by_course: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_course client, req.params.course_id, (materials) ->
        client.end()
        res.send status: 'OK', data: materials
  
  get_materials_by_name_or_description: (req, res) ->
    name_string = req.query.name || null
    Material.connect (client) ->
      Material.get_materials_by_name_or_description client, name_string, (materials) ->
        client.end()
        res.send status: 'OK', data: materials
  
  get_materials_by_category: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_category client, req.params.category_id, (materials) ->
        client.end()
        res.send status: 'OK', data: materials
  
  get_materials_by_keyword: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_keyword client, req.params.keyword_id, (materials) ->
        client.end()
        res.send status: 'OK', data: materials

  get_materials_by_typematerial: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_typematerial client, req.params.typematerial_id, (materials) ->
        client.end()
        res.send status: 'OK', data: materials

  change_state_material: (req, res) ->
    if req.body?.material_id and req.body.state_id?
      params =
        material_id : req.body.material_id
        state_id : req.body.state_id
      Material.connect (client) ->
        Material.change_state_material_by_id client, params, (response) ->
          client.end()
          res.send status: 'OK', data: response

  create_material: (req, res) ->
    Material.connect (client) ->
      Material.create_material client, req.body.material, (response) ->
        client.end()
        if response.status is 'OK' and response.data
          console.log "he creado el material", response.data
          res.send status: 'OK', data: response.data
        else
          res.sendStatus 500
  
  create_material_category: (req, res) ->
    Material.connect (client) ->
      Material.create_material_category client, req.body, (response) ->
        client.end()
        if response.status is 'OK' and response.data
          console.log "he creado la categoria del material", response.data
          res.send status: 'OK', data: response.data
        else
          res.sendStatus 500

  create_material_type: (req, res) ->
    Material.connect (client) ->
      Material.create_material_type client, req.body, (response) ->
        client.end()
        if response.status is 'OK' and response.data
          console.log "he creado el tipo del material", response.data
          res.send status: 'OK', data: response.data
        else
          res.sendStatus 500
  
  create_material_keyword: (req, res) ->
    Material.connect (client) ->
      if req.body.keyword_new
        Material.create_material_keyword_new client, req.body, (response) ->
          client.end()
          if response.status is 'OK' and response.data
            console.log "he creado la palabra clave del material y creada la palabra clave", response.data
            res.send status: 'OK', data: response.data
          else
            res.sendStatus 500
      else
        Material.create_material_keyword client, req.body, (response) ->
          client.end()
          if response.status is 'OK' and response.data
            console.log "he creado la palabra clave del material", response.data
            res.send status: 'OK', data: response.data
          else
            res.sendStatus 500
