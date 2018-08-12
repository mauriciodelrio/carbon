Material = new (require('../../lib/pgconn').Material)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_materials: (req, res) ->
    Material.connect (client) ->
      Material.get_materials client, (materials) ->
        res.send status: 'OK', data: materials

  get_material_by_id: (req, res) ->
    Material.connect (client) ->
      Material.get_material_by_id client, req.params.material_id, (material) ->
        res.send status: 'OK', data: material
  
  get_materials_by_course: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_course client, req.params.course_id, (materials) ->
        res.send status: 'OK', data: materials
  
  get_materials_by_name_or_description: (req, res) ->
    name_string = req.query.name || null
    Material.connect (client) ->
      Material.get_materials_by_name_or_description client, name_string, (materials) ->
        res.send status: 'OK', data: materials
  
  get_materials_by_category: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_category client, req.params.category_id, (materials) ->
        res.send status: 'OK', data: materials
  
  get_materials_by_keyword: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_keyword client, req.params.keyword_id, (materials) ->
        res.send status: 'OK', data: materials

  get_materials_by_typematerial: (req, res) ->
    Material.connect (client) ->
      Material.get_materials_by_typematerial client, req.params.typematerial_id, (materials) ->
        res.send status: 'OK', data: materials
