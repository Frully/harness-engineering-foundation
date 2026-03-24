import fs from 'node:fs';
import path from 'node:path';

const [rootDir, policyPath] = process.argv.slice(2);
if (!rootDir || !policyPath) {
  console.error('usage: frontend_architecture <root> <policy>');
  process.exit(1);
}

const policy = JSON.parse(fs.readFileSync(policyPath, 'utf8')).frontend;
const sourceRoot = path.join(rootDir, policy.sourceRoot);
const layerNames = Object.keys(policy.layers);
const errors = [];

for (const file of listFiles(sourceRoot, ['.ts', '.tsx'])) {
  const relative = path.relative(sourceRoot, file);
  const layer = relative.split(path.sep)[0];
  if (!layerNames.includes(layer)) {
    continue;
  }

  const source = fs.readFileSync(file, 'utf8');
  const imports = parseImports(source);

  for (const specifier of imports) {
    if (policy.forbiddenCrossRuntimePatterns.some((pattern) => specifier.includes(pattern))) {
      errors.push(`${relative} imports forbidden cross-runtime target ${specifier}`);
      continue;
    }

    const targetLayer = resolveLayer(specifier, file, sourceRoot, layerNames);
    if (!targetLayer || targetLayer === layer) {
      continue;
    }

    const allowedTargets = policy.layers[layer];
    if (!allowedTargets.includes(targetLayer)) {
      errors.push(`${relative} (${layer}) imports disallowed frontend layer ${targetLayer}`);
    }
  }
}

if (errors.length > 0) {
  for (const message of errors) {
    console.error(message);
  }
  process.exit(1);
}

function listFiles(directory, extensions) {
  const entries = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      entries.push(...listFiles(fullPath, extensions));
      continue;
    }
    if (extensions.includes(path.extname(entry.name))) {
      entries.push(fullPath);
    }
  }
  return entries;
}

function parseImports(source) {
  const matches = [];
  const patterns = [
    /import\s+[^'"]*['"]([^'"]+)['"]/g,
    /export\s+[^'"]*from\s+['"]([^'"]+)['"]/g,
  ];

  for (const pattern of patterns) {
    for (const match of source.matchAll(pattern)) {
      matches.push(match[1]);
    }
  }

  return matches;
}

function resolveLayer(specifier, filePath, sourceRoot, layers) {
  if (specifier.startsWith('.')) {
    const resolved = resolveRelativeImport(specifier, filePath);
    if (!resolved.startsWith(sourceRoot)) {
      return null;
    }
    const relative = path.relative(sourceRoot, resolved);
    return relative.split(path.sep)[0];
  }

  if (specifier.startsWith('src/')) {
    const relative = specifier.replace(/^src\//, '');
    const layer = relative.split('/')[0];
    return layers.includes(layer) ? layer : null;
  }

  return null;
}

function resolveRelativeImport(specifier, filePath) {
  const base = path.resolve(path.dirname(filePath), specifier);
  const candidates = [
    base,
    `${base}.ts`,
    `${base}.tsx`,
    path.join(base, 'index.ts'),
    path.join(base, 'index.tsx'),
  ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  return base;
}
