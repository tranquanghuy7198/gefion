const hre = require("hardhat");
const fs = require("fs");
const deployInfo = require("../deploy.json");

const CONTRACTS_INFO_PATH = "./contracts-info";

module.exports = async (updateAddresses, verify = true) => {
  // Info
  const [deployer] = await hre.ethers.getSigners();
  const networkName = hre.network.name;
  console.log("Deployer:", deployer.address);
  console.log("Balance:", (await deployer.getBalance()).toString());

  // Deploy and compute encoded constructor arguments
  let encodedArgs = {};
  if (!deployInfo[networkName])
    deployInfo[networkName] = {};
  let contracts = updateAddresses(deployInfo[networkName]);
  for (let i = 0; i < contracts.length; i++) {
    // Deploy
    console.log(`Deploying ${contracts[i].name}: ${contracts[i].constructorArgs.map(arg => `"${arg}"`).join(" ")}`);
    let factory = await hre.ethers.getContractFactory(contracts[i].name);
    let contract = await factory.deploy(...contracts[i].constructorArgs);
    await contract.deployed();
    deployInfo[networkName][contracts[i].name] = contract.address;
    contracts = updateAddresses(deployInfo[networkName]);

    // Compute encoded constructor arguments
    encodedArgs[contracts[i].name] = factory
      .getDeployTransaction(...contracts[i].constructorArgs)
      .data
      .replace(factory.bytecode, "");
  }

  // Save the results
  if (!fs.existsSync(CONTRACTS_INFO_PATH))
    fs.mkdirSync(CONTRACTS_INFO_PATH);
  contracts.forEach(contract => {
    let infoFolder = `${CONTRACTS_INFO_PATH}/${getFolderName(contract.name)}`;
    if (!fs.existsSync(infoFolder))
      fs.mkdirSync(infoFolder);
    fs.writeFileSync(`${infoFolder}/constructor-args.txt`, encodedArgs[contract.name]);
  });
  fs.writeFileSync("deploy.json", JSON.stringify(deployInfo, null, "\t"));
  console.log("Contract address saved! Now verifying...");

  // Wait for the explorer to get the transactions and then verify contracts
  if (verify) {
    await sleep(10000);
    for (let i = 0; i < contracts.length; i++)
      try {
        await hre.run("verify:verify", {
          address: deployInfo[networkName][contracts[i].name],
          constructorArguments: contracts[i].constructorArgs,
          contract: contracts[i].name
        });
      } catch (err) {
        console.log("Error", err);
      }
  }

  console.log("Finish!");
};

let getFolderName = contractName => {
  let splits = contractName.split("/");
  return splits[splits.length - 1].split(".")[0];
};

let sleep = ms => {
  return new Promise(resolve => setTimeout(resolve, ms));
};