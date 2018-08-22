Institution = new (require('../../lib/pgconn').Institution)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_institutions: (req, res) ->
    Institution.connect (client) ->
      Institution.get_institutions client, (institutions) ->
        client.end()
        res.send status: 'OK', data: institutions

  get_points_institution: (req, res) ->
    Institution.connect (client) ->
      Institution.get_points_in_institution client, req.params.ins_id, (points) ->
        client.end()
        res.send status: 'OK', data: points
  
  set_points_institution: (req, res) ->
    Institution.connect (client) ->
      Institution.get_points_in_institution client, req.params.ins_id, (points) ->
        if points.status is 'OK' and points.data?
          Institution.set_points_in_institution client, req.params.ins_id, points.data.sum, (resp_points) ->
            client.end()
            res.send status: 'OK', data: resp_points
        else
          res.send status: 'ERROR', data: points
          console.error resp