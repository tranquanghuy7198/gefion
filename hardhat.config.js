require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');
// require('@openzeppelin/hardhat-defender');
require("@nomiclabs/hardhat-web3");
require('hardhat-contract-sizer');

// Mainnet RPCs
const ETHEREUM_PROVIDER = process.env.ETHEREUM_PROVIDER;
const BSC_PROVIDER = process.env.BSC_PROVIDER;
const JAMCHAIN_PROVIDER = process.env.JAMCHAIN_PROVIDER;
const RONIN_PROVIDER = process.env.RONIN_PROVIDER;
const KARDIACHAIN_PROVIDER = process.env.KARDIACHAIN_PROVIDER;
const KLAYTN_CYPRESS_PROVIDER = process.env.KLAYTN_CYPRESS_PROVIDER;
const POLYGON_PROVIDER = process.env.POLYGON_PROVIDER;

// Testnet RPCs
const RINKEBY_PROVIDER = process.env.RINKEBY_PROVIDER;
const GOERLI_PROVIDER = process.env.GOERLI_PROVIDER;
const SEPOLIA_PROVIDER = process.env.SEPOLIA_PROVIDER;
const BSC_TESTNET_PROVIDER = process.env.BSC_TESTNET_PROVIDER;
const JAMCHAIN_TESTNET_PROVIDER = process.env.JAMCHAIN_TESTNET_PROVIDER;
const POLYGON_TESTNET_PROVIDER = process.env.POLYGON_TESTNET_PROVIDER;
const POLYGON_RPC_BLUEBERRY_PROVIDER = process.env.POLYGON_RPC_BLUEBERRY_PROVIDER;
const RONIN_TESTNET_PROVIDER = process.env.RONIN_TESTNET_PROVIDER;
const AVALANCHE_TESTNET_PROVIDER = process.env.AVALANCHE_TESTNET_PROVIDER;
const KARDIACHAIN_TESTNET_PROVIDER = process.env.KARDIACHAIN_TESTNET_PROVIDER;
const KLAYTN_BAOBAB_PROVIDER = process.env.KLAYTN_BAOBAB_PROVIDER;
const ARBITRUM_GOERLI_PROVIDER = process.env.ARBITRUM_GOERLI_PROVIDER;
const OPTIMISM_GOERLI_PROVIDER = process.env.OPTIMISM_GOERLI_PROVIDER;
const LINEA_GOERLI_PROVIDER = process.env.LINEA_GOERLI_PROVIDER;

// API key
const BSC_API_KEY = process.env.BSC_API_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const POLYGON_API_KEY = process.env.POLYGON_API_KEY;
const AVALANCHE_API_KEY = process.env.AVALANCHE_API_KEY;
const ARBISCAN_API_KEY = process.env.ARBISCAN_API_KEY;
const OPTIMISM_API_KEY = process.env.OPTIMISM_API_KEY;
const LINEA_API_KEY = process.LINEA_API_KEY;

// Account info
const ADDRESS = process.env.ADDRESS;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const MNEMONIC = process.env.MNEMONIC;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    eth: {
      url: ETHEREUM_PROVIDER,
      chainId: 1,
      gas: 8000000,
      accounts: { mnemonic: MNEMONIC }
    },
    bsc: {
      url: BSC_PROVIDER,
      chainId: 56,
      gas: 8000000,
      accounts: { mnemonic: MNEMONIC }
    },
    jamchain: {
      url: JAMCHAIN_PROVIDER,
      chainId: 2077,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    ronin: {
      url: RONIN_PROVIDER,
      chainId: 2020,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    kardiachain: {
      url: KARDIACHAIN_PROVIDER,
      chainId: 24,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    klaytncypress: {
      url: KLAYTN_CYPRESS_PROVIDER,
      chainId: 8217,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    polygon: {
      url: POLYGON_PROVIDER,
      chainId: 137,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    rinkeby: {
      url: RINKEBY_PROVIDER,
      chainId: 4,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    goerli: {
      url: GOERLI_PROVIDER,
      chainId: 5,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    sepolia: {
      url: SEPOLIA_PROVIDER,
      chainId: 11155111,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    bsctestnet: {
      url: BSC_TESTNET_PROVIDER,
      chainId: 97,
      gas: 8000000,
      accounts: { mnemonic: MNEMONIC },
      networkCheckTimeout: 1000000000,
      timeoutBlocks: 200000000,
      skipDryRun: true,
    },
    jamchaintestnet: {
      url: JAMCHAIN_TESTNET_PROVIDER,
      chainId: 2710,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    polygontestnet: {
      url: POLYGON_TESTNET_PROVIDER,
      chainId: 80001,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    polygonzkblueberry: {
      url: POLYGON_RPC_BLUEBERRY_PROVIDER,
      chainId: 1442,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    ronintestnet: {
      url: RONIN_TESTNET_PROVIDER,
      chainId: 2021,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    avalanchetestnet: {
      url: AVALANCHE_TESTNET_PROVIDER,
      chainId: 43113,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    kardiachaintestnet: {
      url: KARDIACHAIN_TESTNET_PROVIDER,
      chainId: 242,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    klaytnbaobab: {
      url: KLAYTN_BAOBAB_PROVIDER,
      chainId: 1001,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    arbitrumgoerli: {
      url: ARBITRUM_GOERLI_PROVIDER,
      chainId: 421613,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    optimismgoerli: {
      url: OPTIMISM_GOERLI_PROVIDER,
      chainId: 420,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    lineagoerli: {
      url: LINEA_GOERLI_PROVIDER,
      chainId: 59140,
      gas: 5500000,
      accounts: { mnemonic: MNEMONIC }
    },
    hardhat: {
      accounts: { mnemonic: MNEMONIC },
      gasLimit: 6000000000,
      defaultBalanceEther: 1000,
    },
    localhost: {
      url: "http://127.0.0.1:7545",
      accounts: { mnemonic: MNEMONIC },
      gasLimit: 6000000000,
      defaultBalanceEther: 10,
    }
  },
  etherscan: {
    apiKey: POLYGON_API_KEY
  },
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
