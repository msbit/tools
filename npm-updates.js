#!/usr/bin/env node

const { spawnSync: spawn } = require('child_process');
const {
  appendFileSync: append,
  readFileSync: read,
  unlinkSync: unlink
} = require('fs');

const diff = (before, after) => {
  const output = {
    added: {},
    modified: {},
    removed: {},
    total: {}
  };

  for (const [key, value] of Object.entries(before)) {
    if (!(key in after)) {
      output.removed[key] = value;
      output.total[key] = value;
      continue;
    }

    if (key in after && value !== after[key]) {
      output.modified[key] = after[key];
      output.total[key] = after[key];
    }

    delete after[key];
  }

  for (const [key, value] of Object.entries(after)) {
    output.added[key] = value;
    output.total[key] = value;
  }

  return output;
};

const exists = (obj) => Object.entries(obj).length > 0;

const getDependencies = () => {
  const { dependencies: deps, devDependencies: devDeps } = JSON.parse(read('package.json'));
  const { dependencies: lockDeps } = JSON.parse(read('package-lock.json'));

  const direct = Object.keys({ ...deps, ...devDeps }).sort();

  const output = {
    direct: {},
    transitive: {}
  };

  direct.forEach((d) => { output.direct[d] = lockDeps[d].version; });

  Object.keys(lockDeps)
    .filter(d => !direct.includes(d))
    .forEach((d) => { output.transitive[d] = lockDeps[d].version; });

  return output;
};

const mktemp = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let tmpFile = 'tmp.';
  for (let i = 0; i < 8; i++) {
    const index = Math.floor(Math.random() * chars.length);
    tmpFile += chars[index];
  }
  return `${process.env.TMPDIR}${tmpFile}`;
};

const writeDependencySet = (file, { added, removed, modified }) => {
  writeDependencies(file, 'Added', added);
  writeDependencies(file, 'Removed', removed);
  writeDependencies(file, 'Modified', modified);
};

const writeDependencies = (file, message, dependencies, prefix = ' ') => {
  if (!exists(dependencies)) { return; }

  append(file, `${prefix}${message}\n\n`);
  for (const [key, value] of Object.entries(dependencies)) {
    append(file, `${prefix} * ${key}: ${value}\n`);
  }
  append(file, '\n');
};

const before = getDependencies();

spawn('rm', ['-rf', 'node_modules', 'package-lock.json'], { stdio: 'inherit' });

spawn('npm', ['install'], { stdio: 'inherit' });

const after = getDependencies();

const direct = diff(before.direct, after.direct);
const transitive = diff(before.transitive, after.transitive);

if (exists(direct.total) || exists(transitive.total)) {
  spawn('git', ['checkout', '-b', `npm-updates-${Date.now()}`], { stdio: 'inherit' });
  spawn('git', ['add', 'package-lock.json'], { stdio: 'inherit' });

  const file = mktemp();

  append(file, 'Dependency updates\n\n');

  if (exists(direct.total)) {
    append(file, 'Direct dependencies\n\n');

    writeDependencySet(file, direct);
  }

  if (exists(transitive.total)) {
    append(file, 'Transitive dependencies\n\n');

    writeDependencySet(file, transitive);
  }

  spawn('git', ['commit', '--file', file], { stdio: 'inherit' });
  unlink(file);
}
