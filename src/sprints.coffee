request = require 'superagent'
Q = require 'q'

sprintqueryUri = (rapidViewId) ->
  '/rest/greenhopper/1.0/sprintquery/' +
  rapidViewId

sprintreportUri =
  '/rest/greenhopper/1.0/rapid/charts/sprintreport'

module.exports = (params) ->
  params.onTotal = params.onTotal || ->
  params.mapCallback = params.mapCallback || (report) -> report
  sprintqueryRequest = ->
    query = request
      .get(params.serverRoot + sprintqueryUri params.rapidView)
      .query
        includeHistoricSprints: true
        includeFutureSprints: true
    if params.user
      query.auth params.user, params.pass
    query
  sprintreportRequest = (sprintId) ->
    query = request
      .get(params.serverRoot + sprintreportUri)
      .query
        rapidViewId: params.rapidView
        sprintId: sprintId
    if params.user
      query.auth params.user, params.pass
    query
  Q()
    .then ->
      Q.ninvoke sprintqueryRequest(), 'end'
    .then (response) ->
      data = response.body
      total = data.sprints.length
      params.onTotal total
      remaining = total
      reportPromise = (sprintId, array) ->
        Q.ninvoke(sprintreportRequest(sprintId), 'end')
          .then (response) ->
            data = response.body
            array.push params.mapCallback data
            array
      reportPromiseCalls = data.sprints.map (sprint) ->
        reportPromise.bind null, sprint.id
      reportPromiseCalls.reduce((soFar, f) ->
        soFar.then(f)
      , Q([]))
