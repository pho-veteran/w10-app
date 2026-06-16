const fs = require("fs");
const path = require("path");

const rootDir = path.resolve(__dirname, "..");
const distDir = path.join(rootDir, "dist");
const publicDir = path.join(rootDir, "public");

fs.rmSync(distDir, { recursive: true, force: true });
fs.mkdirSync(distDir, { recursive: true });
fs.mkdirSync(path.join(distDir, "public"), { recursive: true });

for (const fileName of ["index.html", "app.js", "styles.css"]) {
  fs.copyFileSync(path.join(publicDir, fileName), path.join(distDir, "public", fileName));
}

fs.copyFileSync(path.join(rootDir, "server.js"), path.join(distDir, "server.js"));
fs.copyFileSync(path.join(rootDir, "package.json"), path.join(distDir, "package.json"));

console.log(`Build artifacts generated in ${distDir}`);
