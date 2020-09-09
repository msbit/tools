#!/usr/bin/env node

const { spawnSync } = require('child_process');
const { appendFileSync, unlinkSync } = require('fs');

const { determineDependencyChanges, exists, mktemp, writeDependencySet } = require('./npm-common.js');

const action = () => {
  spawnSync('rm', ['-rf', 'node_modules', 'package-lock.json'], {
    stdio: 'inherit'
  });
  spawnSync('npm', ['install'], {
    stdio: 'inherit'
  });
};

const reaction = (direct, transitive) => {
  spawnSync('git', ['checkout', '-b', `npm-updates-${Date.now()}`], {
    stdio: 'inherit'
  });
  spawnSync('git', ['add', 'package-lock.json'], {
    stdio: 'inherit'
  });

  const file = mktemp();

  appendFileSync(file, 'Dependency updates\n\n');

  if (exists(direct.total)) {
    appendFileSync(file, 'Direct dependencies\n\n');

    writeDependencySet(file, direct);
  }

  if (exists(transitive.total)) {
    appendFileSync(file, 'Transitive dependencies\n\n');

    writeDependencySet(file, transitive);
  }

  spawnSync('git', ['commit', '--file', file], {
    stdio: 'inherit'
  });
  unlinkSync(file);
};

determineDependencyChanges(action, reaction);
