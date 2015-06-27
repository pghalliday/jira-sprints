sprints = require '../../src/sprints'
jira = require '../../mock/jira'
port = 3000
chai = require 'chai'
chai.should()

describe 'sprints', ->
  before ->
    jira.start port
  after ->
    jira.stop()
  it 'should pass', ->
    issues = []
    sprints(
      serverRoot: 'https://localhost:' + port
      strictSSL: false
      user: 'myuser'
      pass: 'mypassword'
      rapidView: 456
      onTotal: (total) ->
        total.should.equal 5
      mapCallback: (report) ->
        report.sprint.id
    )
      .then (sprints) ->
        jira.sprintqueryRequests.should.have.length 1
        jira.sprintqueryRequests[0].user.should.equal 'myuser'
        jira.sprintqueryRequests[0].pass.should.equal 'mypassword'
        jira.sprintqueryRequests[0].rapidViewId.should.equal 456
        jira.sprintqueryRequests[0].includeHistoricSprints.should.equal true
        jira.sprintqueryRequests[0].includeFutureSprints.should.equal true
        jira.sprintreportRequests.should.have.length 5
        jira.sprintreportRequests[0].user.should.equal 'myuser'
        jira.sprintreportRequests[0].pass.should.equal 'mypassword'
        jira.sprintreportRequests[0].rapidViewId.should.equal 456
        jira.sprintreportRequests[0].sprintId.should.equal 1
        jira.sprintreportRequests[1].user.should.equal 'myuser'
        jira.sprintreportRequests[1].pass.should.equal 'mypassword'
        jira.sprintreportRequests[1].rapidViewId.should.equal 456
        jira.sprintreportRequests[1].sprintId.should.equal 2
        jira.sprintreportRequests[2].user.should.equal 'myuser'
        jira.sprintreportRequests[2].pass.should.equal 'mypassword'
        jira.sprintreportRequests[2].rapidViewId.should.equal 456
        jira.sprintreportRequests[2].sprintId.should.equal 3
        jira.sprintreportRequests[3].user.should.equal 'myuser'
        jira.sprintreportRequests[3].pass.should.equal 'mypassword'
        jira.sprintreportRequests[3].rapidViewId.should.equal 456
        jira.sprintreportRequests[3].sprintId.should.equal 4
        jira.sprintreportRequests[4].user.should.equal 'myuser'
        jira.sprintreportRequests[4].pass.should.equal 'mypassword'
        jira.sprintreportRequests[4].rapidViewId.should.equal 456
        jira.sprintreportRequests[4].sprintId.should.equal 5
        sprints.should.deep.equal [1..5]
