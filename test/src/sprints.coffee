sprints = require '../../src/sprints'
jira = require '../../mock/jira'
port = 3000
chai = require 'chai'
chai.should()

describe 'search', ->
  before ->
    jira.start port
  after ->
    jira.stop()
  it 'should pass', ->
    issues = []
    search(
      serverRoot: 'https://localhost:' + port
      strictSSL: false
      user: 'myuser'
      pass: 'mypassword'
      rapidView: 0
      onTotal: (total) ->
        total.should.equal 5
      mapCallback: (report) ->
        report.sprint.id
    )
      .then (sprints) ->
        jira.sprintqueryRequests.should.have.length 1
        jira.sprintreportRequests.should.have.length 5
        sprints.should.deep.equal [1..5]
