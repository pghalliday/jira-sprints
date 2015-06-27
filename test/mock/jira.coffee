jira = require '../../mock/jira'
request = require 'request'
Q = require 'q'
port = 3000
chai = require 'chai'
chai.should()

sprintqueryUri = (rapidViewId) ->
  'https://localhost:' +
  port +
  '/rest/greenhopper/1.0/sprintquery/' +
  rapidViewId

sprintreportUri =
  'https://localhost:' +
  port +
  '/rest/greenhopper/1.0/rapid/charts/sprintreport'

describe 'jira', ->
  describe 'start/stop', ->
    it 'should maintain array of requests', ->
      jira.sprintqueryRequests.should.have.length 0
      jira.sprintreportRequests.should.have.length 0
      jira.start(port)
        .then ->
          Q.nfcall(
            request,
            strictSSL: false
            method: 'Get'
            uri: sprintqueryUri 573
            auth:
              user: 'user'
              pass: 'pass'
              sendImmediately: true
            qs:
              includeHistoricSprints: true
              includeFutureSprints: true
          )
        .spread (response, body) ->
          response.statusCode.should.equal 200
          data = JSON.parse body
          data.should.deep.equal
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
          jira.sprintqueryRequests.should.have.length 1
          jira.sprintreportRequests.should.have.length 0
          jira.sprintqueryRequests[0].rapidViewId.should.equal 573
          jira.sprintqueryRequests[0].includeHistoricSprints.should.equal true
          jira.sprintqueryRequests[0].includeFutureSprints.should.equal true
          jira.sprintqueryRequests[0].user.should.equal 'user'
          jira.sprintqueryRequests[0].pass.should.equal 'pass'
          Q.nfcall(
            request,
            strictSSL: false
            method: 'Get'
            uri: sprintqueryUri 123
            auth:
              user: 'user'
              pass: 'pass'
              sendImmediately: true
            qs:
              includeHistoricSprints: false
              includeFutureSprints: true
          )
        .spread (response, body) ->
          response.statusCode.should.equal 200
          jira.sprintqueryRequests.should.have.length 2
          jira.sprintreportRequests.should.have.length 0
          jira.sprintqueryRequests[1].rapidViewId.should.equal 123
          jira.sprintqueryRequests[1].includeHistoricSprints.should.equal false
          jira.sprintqueryRequests[1].includeFutureSprints.should.equal true
          jira.sprintqueryRequests[1].user.should.equal 'user'
          jira.sprintqueryRequests[1].pass.should.equal 'pass'
          Q.nfcall(
            request,
            strictSSL: false
            method: 'Get'
            uri: sprintreportUri
            auth:
              user: 'user'
              pass: 'pass'
              sendImmediately: true
            qs:
              rapidViewId: 573
              sprintId: 2
          )
        .spread (response, body) ->
          response.statusCode.should.equal 200
          data = JSON.parse body
          data.should.deep.equal
            sprint:
              id: 2
          jira.sprintqueryRequests.should.have.length 2
          jira.sprintreportRequests.should.have.length 1
          jira.sprintreportRequests[0].rapidViewId.should.equal 573
          jira.sprintreportRequests[0].sprintId.should.equal 2
          jira.sprintreportRequests[0].user.should.equal 'user'
          jira.sprintreportRequests[0].pass.should.equal 'pass'
          jira.stop()
        .then ->
          jira.sprintqueryRequests.should.have.length 0
          jira.sprintreportRequests.should.have.length 0
