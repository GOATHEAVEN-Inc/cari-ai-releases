import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import vm from "node:vm";

const html = readFileSync(new URL("../index.html", import.meta.url), "utf8");
const source = html.match(/var RELEASES_BASE =[^]*?function platformUrl\(key\) \{[^]*?\}/)[0];
const context = vm.createContext({});
vm.runInContext(source, context);
assert.equal(context.platformUrl("mac"), "https://github.com/GOATHEAVEN-Inc/cari-ai-releases/releases/latest/download/CariAI.dmg");
assert.equal(context.platformUrl("win"), "https://github.com/GOATHEAVEN-Inc/cari-ai-releases/releases/latest/download/CariAI.exe");
assert.equal(context.platformUrl("linux"), "#terminal");
assert.ok(!html.includes("CariAI.AppImage"), "Unavailable AppImage links must not be generated");
console.log("Download links passed: released macOS/Windows files and Linux terminal instructions.");
