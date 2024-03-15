const fs = require("fs");
const { execSync } = require("child_process");

const SOURCE_PATH = "./contracts";
const CONTRACT_PATH = "./artifacts/contracts";
const CONTRACTS_INFO_PATH = "./contracts-info";

/* Flatten all contracts */
let browseSourceFolder = path => {
  if (fs.lstatSync(path).isDirectory()) {
    fs.readdir(path, (err, items) => {
      if (err) {
        console.log(`Error while browsing ${path}`);
        process.exit(1);
      }
      items.forEach((item, _) => browseSourceFolder(path + "/" + item));
    });
  } else {
    let splitPath = path.split("/");
    let baseName = splitPath[splitPath.length - 1].split(".")[0];
    if (baseName && baseName.charAt(0) !== "I") {
      if (!fs.existsSync(`${CONTRACTS_INFO_PATH}/${baseName}`))
        fs.mkdirSync(`${CONTRACTS_INFO_PATH}/${baseName}`);
      let flattenedFile = `${CONTRACTS_INFO_PATH}/${baseName}/flatten.txt`;
      let flattenResult = execSync(`npx hardhat flatten ${path} > ${flattenedFile}`).toString();
      if (flattenResult !== "") {
        console.log(`Error when flattening ${baseName}!`, flattenResult);
        process.exit(1);
      }
      let flattenedCode = fs.readFileSync(flattenedFile).toString();
      let removeSPDX = flattenedCode.split("\n").filter(line => !line.includes("SPDX")).join("\n");
      let finalCode = "/* SPDX-License-Identifier: MIT */\n\n" + removeSPDX;
      fs.writeFileSync(flattenedFile, finalCode);
    }
  }
};

/* Extract ABI and BIN parts from the compiled result */
let browseBuildFolder = path => {
  if (fs.lstatSync(path).isDirectory()) {
    fs.readdir(path, (err, items) => {
      if (err) {
        console.error(`Error while browsing ${path}`);
        process.exit(1);
      }
      items.forEach((item, _) => browseBuildFolder(path + "/" + item));
    });
  } else if (path.slice(-9) !== ".dbg.json") {
    let splitPath = path.split("/");
    let baseName = splitPath[splitPath.length - 1].split(".")[0];
    let rawData = fs.readFileSync(path);
    let info = JSON.parse(rawData);
    let { abi, bytecode } = info;
    bytecode = bytecode.substring(2);

    if (abi.length !== 0) {
      if (!fs.existsSync(`${CONTRACTS_INFO_PATH}/${baseName}`))
        fs.mkdirSync(`${CONTRACTS_INFO_PATH}/${baseName}`);
      fs.writeFileSync(`${CONTRACTS_INFO_PATH}/${baseName}/abi.txt`, JSON.stringify(abi, null, "\t"));
      fs.writeFileSync(`${CONTRACTS_INFO_PATH}/${baseName}/bin.txt`, bytecode);
    }
  }
};

let main = () => {
  // Compile all contracts again
  execSync(`npx hardhat compile`);

  // Create empty dirs
  if (!fs.existsSync(CONTRACTS_INFO_PATH))
    fs.mkdirSync(CONTRACTS_INFO_PATH);

  // Loop through all the files in the temp directory
  browseBuildFolder(CONTRACT_PATH);
  browseSourceFolder(SOURCE_PATH);
};

main();