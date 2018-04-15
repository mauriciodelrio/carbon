###
jwt = require('../lib/jwt')
_ = require 'lodash'

middleware = (req, res, next) ->
  auth = _.get req, 'headers.authorization', undefined
  jwt.verifyToken auth, (err, decoded) ->
    res.locals.user = decoded
    if err
      res.status(401).send err
    else
      next()

module.exports = middleware
###