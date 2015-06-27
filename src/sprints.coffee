request = require 'request'
Q = require 'q'

sprintqueryUri = (rapidViewId) ->
  '/rest/greenhopper/1.0/sprintquery/' +
  rapidViewId

sprintreportUri =
  '/rest/greenhopper/1.0/rapid/charts/sprintreport'

module.exports = (params) ->
  params.onTotal = params.onTotal || ->
  params.mapCallback = params.mapCallback || (report) -> report
  sprintqueryParams =
    method: 'GET'
    strictSSL: params.strictSSL
    auth:
      user: params.user
      pass: params.pass
      sendImmediately: true
    uri: params.serverRoot + sprintqueryUri params.rapidView
    qs:
      includeHistoricSprints: true
      includeFutureSprints: true
  sprintreportParams = (sprintId) ->
    method: 'GET'
    strictSSL: params.strictSSL
    auth:
      user: params.user
      pass: params.pass
      sendImmediately: true
    uri: params.serverRoot + sprintreportUri
    qs:
      rapidViewId: params.rapidView
      sprintId: sprintId
  Q()
    .then ->
      Q.nfcall request, sprintqueryParams
    .spread (response, body) ->
      data = JSON.parse body
      total = data.sprints.length
      params.onTotal total
      remaining = total
      reportPromise = (sprintId, array) ->
        Q.nfcall(request, sprintreportParams sprintId)
          .spread (response, body) ->
            data = JSON.parse body
            array.push params.mapCallback data
            array
      reportPromiseCalls = data.sprints.map (sprint) ->
        reportPromise.bind null, sprint.id
      reportPromiseCalls.reduce((soFar, f) ->
        soFar.then(f)
      , Q([]))
