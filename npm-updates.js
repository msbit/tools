#!/usr/bin/env node

const { spawnSync } = require('child_process');
const { appendFileSync, readFileSync, unlinkSync } = require('fs');

function diff (before, after, output) {
  for (const key in before) {
    if (!(key in after)) {
      output.removed[key] = before[key];
      output.total[key] = before[key];
      continue;
    }

    if (key in after && before[key] !== after[key]) {
      output.modified[key] = after[key];
      output.total[key] = after[key];
    }
    delete after[key];
  }

  for (const key in after) {
    output.added[key] = after[key];
    output.total[key] = after[key];
  }
}

function exists (obj) {
  return Object.entries(obj).length > 0;
}

function getDependencies () {
  const pkg = JSON.parse(readFileSync('package.json'));
  const pkgLock = JSON.parse(readFileSync('package-lock.json'));

  const direct = Object.keys({
    ...pkg.dependencies,
    ...pkg.devDependencies
  }).sort();

  const transitive = Object.keys(pkgLock.dependencies).filter(d => !direct.includes(d));

  const output = {
    direct: {},
    transitive: {}
  };

  direct.forEach((d) => {
    output.direct[d] = pkgLock.dependencies[d].version;
  });

  transitive.forEach((d) => {
    output.transitive[d] = pkgLock.dependencies[d].version;
  });

  return output;
}

function mktemp () {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let tmpFile = 'tmp.';
  for (let i = 0; i < 8; i++) {
    const index = Math.floor(Math.random() * chars.length);
    tmpFile += chars[index];
  }
  return `${process.env.TMPDIR}${tmpFile}`;
}

function writeDependencies (file, message, dependencies, prefix = ' ') {
  if (exists(dependencies)) {
    appendFileSync(file, `${prefix}${message}\n\n`);
    for (const [key, value] of Object.entries(dependencies)) {
      appendFileSync(file, `${prefix} * ${key}: ${value}\n`);
    }
    appendFileSync(file, '\n');
  }
}

const before = getDependencies();

spawnSync('rm', ['-rf', 'node_modules', 'package-lock.json'], { stdio: 'inherit' });

spawnSync('npm', ['install'], { stdio: 'inherit' });

const after = getDependencies();

const direct = {
  added: {},
  modified: {},
  removed: {},
  total: {}
};

const transitive = {
  added: {},
  modified: {},
  removed: {},
  total: {}
};

diff(before.direct, after.direct, direct);
diff(before.transitive, after.transitive, transitive);

if (exists(direct.total) || exists(transitive.total)) {
  spawnSync('git', ['checkout', '-b', `npm-updates-${Date.now()}`], { stdio: 'inherit' });
  spawnSync('git', ['add', 'package-lock.json'], { stdio: 'inherit' });

  const commitMessageFile = mktemp();
  console.log(commitMessageFile);

  appendFileSync(commitMessageFile, 'Dependency updates\n\n');

  if (exists(direct.total)) {
    appendFileSync(commitMessageFile, 'Direct dependencies\n\n');

    writeDependencies(commitMessageFile, 'Added', direct.added);
    writeDependencies(commitMessageFile, 'Removed', direct.removed);
    writeDependencies(commitMessageFile, 'Modified', direct.modified);
  }

  if (exists(transitive.total)) {
    appendFileSync(commitMessageFile, 'Transitive dependencies\n\n');

    writeDependencies(commitMessageFile, 'Added', transitive.added);
    writeDependencies(commitMessageFile, 'Removed', transitive.removed);
    writeDependencies(commitMessageFile, 'Modified', transitive.modified);
  }

  spawnSync('git', ['commit', '--file', commitMessageFile], { stdio: 'inherit' });
  unlinkSync(commitMessageFile);
}
