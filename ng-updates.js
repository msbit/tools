#!/usr/bin/env node

const { spawnSync } = require('child_process');
const { appendFileSync, readFileSync, unlinkSync } = require('fs');

const {
  determineDependencyChanges,
  exists,
  mktemp,
  writeDependencySet
} = require('./node-common.js');

const action = () => {
  const {
    dependencies: runtime,
    devDependencies: development
  } = JSON.parse(readFileSync('package.json'));

  const dependencies = Object.assign(runtime, development);

  spawnSync('npm', ['install'], { stdio: 'inherit' });

  const specs = Object.entries(dependencies).map(([pkg, spec]) => {
    return `${pkg}@${spec}`;
  });

  spawnSync('ng', ['update', ...specs], { stdio: 'inherit' });
};

const reaction = (direct, transitive) => {
  spawnSync('git', ['checkout', '-b', `ng-updates-${Date.now()}`], {
    stdio: 'inherit'
  });
  spawnSync('git', ['add', '*'], {
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
