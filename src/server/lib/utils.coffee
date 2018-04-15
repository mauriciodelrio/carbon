ip = require 'ip'
_ = require 'lodash'
Promise = require 'bluebird'

log = (text = '', type = 'info') ->
  if type is 'info' or (type is 'debug' and process.env.DEBUG is 'true') or (type is 'debug' and process.env.NODE_ENV is 'development')
    d = new Date()
    console.log "[#{String(d.getUTCFullYear())}-#{"0".concat(String(d.getUTCMonth()+1)).substr(-2)}-#{"0".concat(String(d.getUTCDate())).substr(-2)} #{"0".concat(String(d.getUTCHours())).substr(-2)}:#{"0".concat(String(d.getUTCMinutes())).substr(-2)}:#{"0".concat(String(d.getUTCSeconds())).substr(-2)}] [#{type.toUpperCase()}]: #{text}"

format_number = (number, decimals = 0, thousand_separator = '.', decimal_separator = ',', currency_symbol = '') ->
  sign = if number < 0 then '-' else ''
  i = "#{parseInt(number = Math.abs(+number or 0).toFixed(decimals))}#{''}"
  j = (if (j = i.length) > 3 then j % 3 else 0)
  "#{sign}#{currency_symbol}#{((if j then "#{i.substr(0, j)}#{thousand_separator}" else ''))}#{i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand_separator)}#{((if decimals then "#{decimal_separator}#{Math.abs(number - i).toFixed(decimals).slice(2)}" else ''))}"

get_public_ips = (ips = []) -> _.filter (ips), (_ip) -> !ip.isPrivate(_ip)

path_resolver = (root, path, method) -> "#{root}#{path}/#{method}"

random_string = () ->
  text = ""
  possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  i = 0
  while i < 8
    text += possible.charAt(Math.floor(Math.random() * possible.length))
    i++
  return text

validate_email = (email) ->
  return new Promise (resolve, reject) ->
    if /^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/i.test(email)
      return  resolve email.trim().toLowerCase()
    else
      return reject 'failed'

xml_to_object = (xml) ->
  # Create the return object
  obj = {}
  if xml.nodeType == 1
    # element
    # do attributes
    if xml.attributes.length > 0
      obj['@attributes'] = {}
      j = 0
      while j < xml.attributes.length
        attribute = xml.attributes.item(j)
        obj['@attributes'][attribute.nodeName] = attribute.nodeValue
        j++
  else if xml.nodeType == 3
    # text
    obj = xml.nodeValue
  # do children
  # If just one text node inside
  if xml.hasChildNodes() and xml.childNodes.length == 1 and xml.childNodes[0].nodeType == 3
    obj = xml.childNodes[0].nodeValue
  else if xml.hasChildNodes()
    i = 0
    while i < xml.childNodes.length
      item = xml.childNodes.item(i)
      nodeName = item.nodeName
      if typeof obj[nodeName] == 'undefined'
        obj[nodeName] = xmlToJson(item)
      else
        if typeof obj[nodeName].push == 'undefined'
          old = obj[nodeName]
          obj[nodeName] = []
          obj[nodeName].push old
        obj[nodeName].push xmlToJson(item)
      i++
  obj

compareYears = (years) -> (playlist) ->
  parseInt(years) >= parseInt _.get(playlist, 'data.custom.years-category', 0)

parser = (playlist) ->
  key: "CN_PLAYLISTS_#{_.get playlist, 'data.custom.years-category', 0}"
  value: _.get playlist, 'data.custom.years-category', 0

exports.log = log
exports.format_number = format_number
exports.get_public_ips = get_public_ips
exports.path_resolver = path_resolver

exports.xml_to_object = xml_to_object
exports.random_string = random_string
exports.validate_email = validate_email

exports.compareYears = compareYears
exports.parser = parser