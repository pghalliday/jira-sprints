jira-sprints
============

[![Build Status](https://travis-ci.org/pghalliday/jira-sprints.svg?branch=master)](https://travis-ci.org/pghalliday/jira-sprints)

Promise based NodeJS library to perform queries on JIRA sprint reports

Usage
-----

```
npm install jira-sprints
```

```javascript
var sprints = require('jira-sprints');

sprints({
  serverRoot: 'https://my.jira.server', // the base URL for the JIRA server
  user: 'myuser', // the user name
  pass: 'mypassword', // the password
  rapidView: 625, // the rapidView ID
  onTotal: function (total) {
    // optionally initialise a progress bar or something
  },
  mapCallback: function (report) {
    // This will be called for each sprint report
    // Update a progress bar or something if you want here.
    // The return value from this function will be added
    // to the array returned by the promise.
    // If omitted the default behaviour is to add the whole sprint report
    return report.sprint.id;
  }
}).then(function (sprints) {
  // consume the collected sprints array here
}).done();
```
