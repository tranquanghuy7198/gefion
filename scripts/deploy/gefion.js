const baseDeploy = require("../base-deploy");

const ROUTER = "contracts/core/GefionRouter.sol:GefionRouter";
const FACTORY = "contracts/core/GefionFactory.sol:GefionFactory";
const VAULT = "contracts/core/GefionVault.sol:GefionVault";
const USDT = "contracts/token/USDT.sol:USDT";
const DUMMY_ADDRESS = "0x0000000000000000000000000000000000000000";

let updateAddresses = (addresses) => {
  return [
    {
      name: FACTORY,
      constructorArgs: []
    },
    {
      name: ROUTER,
      constructorArgs: [addresses[FACTORY]]
    },
    {
      name: USDT,
      constructorArgs: []
    },
    {
      name: VAULT,
      constructorArgs: [DUMMY_ADDRESS, DUMMY_ADDRESS, "", "", 7500, DUMMY_ADDRESS]
    }
  ];
};

baseDeploy(updateAddresses, true);