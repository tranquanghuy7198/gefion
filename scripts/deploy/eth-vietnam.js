const baseDeploy = require("../base-deploy");

const ROUTER = "contracts/core/HeimdallrRouter.sol:HeimdallrRouter";
const FACTORY = "contracts/core/OdinFactory.sol:OdinFactory";
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