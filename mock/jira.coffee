fs = require 'fs'
Q = require 'q'
https = require 'https'
url = require 'url'

sprintreportPathname = '/rest/greenhopper/1.0/rapid/charts/sprintreport'
sprintqueryRegex = new RegExp '\/rest\/greenhopper\/1\.0\/sprintquery\/([0-9]*)'

sprintqueryResult =
  sprints: [
    id: 1
  ,
    id: 2
  ,
    id: 3
  ,
    id: 4
  ,
    id: 5
  ]

sprintreportResults = [
  sprint:
    id: 1
,
  sprint:
    id: 2
,
  sprint:
    id: 3
,
  sprint:
    id: 4
,
  sprint:
    id: 5
]

jira =
  start: (port) ->
    Q.ninvoke server, 'listen', port
  stop: ->
    Q.ninvoke server, 'close'
    jira.sprintqueryRequests = []
    jira.sprintreportRequests = []
  sprintqueryRequests: []
  sprintreportRequests: []

options =
  key: fs.readFileSync 'test/certs/server.key'
  cert: fs.readFileSync 'test/certs/server.crt'
  passphrase: 'passphrase'
server = https.createServer options, (request, response) ->
  authBuffer = new Buffer(
    request.headers.authorization.substring(6)
    'base64'
  )
  auth = authBuffer.toString 'ascii'
  authRegex = new RegExp '([^:]*):(.*)'
  authMatch = auth.match authRegex
  if authMatch
    handleRequest request, response, authMatch[1], authMatch[2]
  else
    response.writeHead 401
    response.end()
    
handleRequest = (request, response, user, pass) ->
  requestUrl = url.parse request.url, true
  query = requestUrl.query
  sprintqueryMatch = requestUrl.pathname.match sprintqueryRegex
  if sprintqueryMatch
    handleSprintqueryRequest sprintqueryMatch[1], query, user, pass, response
  else if requestUrl.pathname is sprintreportPathname
    handleSprintreportRequest query, user, pass, response
  else
    response.writeHead 404
    response.end()

handleSprintqueryRequest = (rapidViewId, query, user, pass, response) ->
  jira.sprintqueryRequests.push
    user: user
    pass: pass
    rapidViewId: parseInt rapidViewId
    includeHistoricSprints: query.includeHistoricSprints is 'true'
    includeFutureSprints: query.includeFutureSprints is 'true'
  response.writeHead 200,
    'Content-Type': 'application/json'
  response.end JSON.stringify sprintqueryResult

handleSprintreportRequest = (query, user, pass, response) ->
  sprintId = parseInt query.sprintId
  jira.sprintreportRequests.push
    user: user
    pass: pass
    rapidViewId: parseInt query.rapidViewId
    sprintId: sprintId
  response.writeHead 200,
    'Content-Type': 'application/json'
  response.end JSON.stringify sprintreportResults[sprintId - 1]

module.exports = jira
