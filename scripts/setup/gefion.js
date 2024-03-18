const hre = require("hardhat");
const deployInfo = require("../../deploy.json");

const ROUTER = "contracts/core/GefionRouter.sol:GefionRouter";
const FACTORY = "contracts/core/GefionFactory.sol:GefionFactory";
const DEX_ROUTERS = [
  // "0xC458eED598eAb247ffc19d15F19cf06ae729432c", // Polygon zK DEX Router
  // "0xBe52f99259e67bE57F362E1AC67703Cf52b858d8", // PancakeSwap Router on Polygon Mumbai
  "0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6" // Uniswap Router on Polygon Mainnet
  // "0x5aE305B45d41759603692e1Bc3B4eAFf45dd07e2" // Linea Testnet
  // "0x73f5F13311D969641d3515ac63c7eE31a61293c8" // Polygon ZK Testnet
  // "0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb" // PancakeSwap Router on Linea Mainnet
];

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