
middleware = (req, res, next) ->
  console.log " ================== CORS ================== ", req.get('Origin')
  res.set 'Access-Control-Allow-Origin', req.get('Origin') or '*'
  res.set 'Access-Control-Allow-Credentials', 'true'
  res.set 'Access-Control-Allow-Methods', 'GET, POST, Origin, X-Requested-With, Content-Type, Accept'
  res.set 'Access-Control-Allow-Headers', 'X-API-Token, Origin, X-Requested-With, Content-Type, Accept, Cookie, X-SESSION-ID, X-CUSTOMER-ID, Authorization'
  if req.method is 'OPTIONS'
    res.sendStatus 200
  else
    next()

module.exports = middleware
