// Entry point for the gta6-clipper-01 bounty.
// Job: hand VIDEO.json from this repository to the grader by copying it
// into the output directory. Nothing else about the video is judged here —
// the house reads the video itself through the YouTube Data API.
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, resolve } from "node:path";

const repoDir = resolve(process.env.MAKEFUN_BOT_DIR ?? ".");
const outDir = resolve(process.env.MAKEFUN_OUTPUT_DIR ?? "/output");

const sourcePath = join(repoDir, "VIDEO.json");
const targetPath = join(outDir, "VIDEO.json");

mkdirSync(outDir, { recursive: true });

const payload = readFileSync(sourcePath, "utf8");

// Validate before handing it on: the entry is refused if VIDEO.json does
// not parse, or if its url is not a YouTube video address.
const parsed: unknown = JSON.parse(payload);
if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
  throw new Error(`VIDEO.json must be a JSON object, got: ${payload.trim()}`);
}
const url = (parsed as Record<string, unknown>).url;
const youtubePattern =
  /^https:\/\/(www\.|m\.)?(youtube\.com\/(shorts\/|watch\?v=)|youtu\.be\/)[A-Za-z0-9_-]{11}($|[?#])/;
if (typeof url !== "string" || !youtubePattern.test(url)) {
  throw new Error(`VIDEO.json url is not a YouTube video address: ${String(url)}`);
}

writeFileSync(targetPath, payload);

console.log(`copied ${sourcePath} -> ${targetPath}`);
console.log(`video url OK: ${url}`);
