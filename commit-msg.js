#!/usr/bin/env node

const fs = require('fs');

const MESSAGE_PATTERN = /^(fix|feat|BREAKING CHANGE|chore|docs|style|refactor|perf|test)\((release|NoTicket|[A-Z]+-\d+)\): .*/;

const message = fs.readFileSync(process.env.HUSKY_GIT_PARAMS, 'utf8').trim();

if (!MESSAGE_PATTERN.test(message)) {
  console.log('Bad commit message.');
  console.log();
  console.log('The commit message should be structured as follows:');
  console.log('<type>[jira]: <description>');
  console.log('[optional body]');
  console.log('[optional footer]');
  console.log();
  console.log(
    'type is one of fix, feat, BREAKING CHANGE, chore, docs, style, refactor, perf or test'
  );
  console.log('jira is your jira ticket keyword or NoTicket');
  process.exit(1);
}

process.exit(0);
