const hre = require("hardhat");
const deployInfo = require("../../deploy.json");

const ROUTER = "contracts/core/GefionRouter.sol:GefionRouter";
const FACTORY = "contracts/core/GefionFactory.sol:GefionFactory";
const DEX_ROUTERS = ["0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"]; // Polygon Mumbai DEX Routers

const setup = async () => {
  // Info
  const [deployer] = await hre.ethers.getSigners();
  const networkName = hre.network.name;
  console.log("Deployer:", deployer.address);
  console.log("Balance:", (await deployer.getBalance()).toString());

  // Prepare contracts
  const factory = await hre.ethers.getContractFactory(FACTORY);
  const factoryContract = factory.attach(deployInfo[networkName][FACTORY]);

  // Set router address
  console.log("Setting router address...");
  await factory
    .connect(deployer)
    .attach(factoryContract.address)
    .setRouter(deployInfo[networkName][ROUTER]);

  // Set DEX router addresses
  console.log("Setting DEX router addresses...");
  await factory
    .connect(deployer)
    .attach(factoryContract.address)
    .addDexRouters(DEX_ROUTERS);
};

setup();