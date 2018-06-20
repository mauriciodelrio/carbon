User = new (require('../../lib/pgconn').User)()
Institution = new (require('../../lib/pgconn').Institution)()
Cache = new (require('../../lib/cache'))()
Session = new (require('../../lib/session'))()
_ = require 'lodash'
moment = require 'moment'
module.exports = () ->

  all_institutions: (req, res) ->
    Institution.connect (client) ->
      Institution.get_institutions client, (institutions) ->
        res.send status: 'OK', data: institutions

  get_points_institution: (req, res) ->
    Institution.connect (client) ->
      Institution.get_points_in_institution client, req.params.ins_id, (points) ->
        res.send status: 'OK', data: points
  
  set_points_institution: (req, res) ->
    Institution.connect (client) ->
      Institution.get_points_in_institution client, req.params.ins_id, (points) ->
        if points.status is 'OK' and points.data?
          Institution.set_points_in_institution client, req.params.ins_id, points.data.sum, (resp_points) ->
            res.send status: 'OK', data: resp_points
        else
          res.send status: 'ERROR', data: points
          console.error resp