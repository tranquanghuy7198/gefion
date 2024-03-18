const baseDeploy = require("../base-deploy");

const ADA = "contracts/test/ADA.sol:ADA";
const USDT = "contracts/test/USDT.sol:USDT";
const ROUTER = "contracts/core/GefionRouter.sol:GefionRouter";
const FACTORY = "contracts/core/GefionFactory.sol:GefionFactory";
const VAULT = "contracts/core/GefionVault.sol:GefionVault";
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
      name: ADA,
      constructorArgs: []
    },
    {
      name: VAULT,
      constructorArgs: [DUMMY_ADDRESS, DUMMY_ADDRESS, "", "", 7500, DUMMY_ADDRESS]
    }
  ];
};

baseDeploy(updateAddresses, true);