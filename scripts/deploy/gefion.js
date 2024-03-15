const baseDeploy = require("../base-deploy");

const ROUTER = "contracts/core/GefionRouter.sol:GefionRouter";
const FACTORY = "contracts/core/GefionFactory.sol:GefionFactory";
const USDT = "contracts/token/USDT.sol:USDT";

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
    }
  ];
};

baseDeploy(updateAddresses, true);