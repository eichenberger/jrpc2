httpListener = (server) ->
  (req, res) ->
    data = ""
    req.on 'data', (chunk) ->
      data += chunk
    req.on 'end', ->
      if req.cookies
        req.headers.cookies = req.cookies
      if req.query
        req.headers.query = req.query
      req.headers.ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress
      server.handleRequest data, req.headers, (answer) ->
        if answer
          res.writeHead 200, {'Content-Type': 'application/json'}
          res.write JSON.stringify answer
        res.emit 'close'
        res.end()

exports.middleware = (server) ->
  listener = httpListener server
  (req, res, next) =>
    if req.method is 'POST'
      listener req, res
    else
      next()

exports.httpListener =  httpListener