# GEFION

## About this project

Gefion serves as a decentralized protocol built on the Ethereum network, facilitating on-chain assets management. It offers individuals and organizations a secure and adaptable platform for overseeing their own finances as well as those of others. Gefion grants the capability to create, administer, and invest in tailor-made on-chain financial instruments.

## Supported Network ##

- BNB
- Polygon
- Linea
- ETH

## Hackathon Bounty ##

**SolidityScan**

![image](https://github.com/tranquanghuy7198/gefion/assets/24476347/17d7600d-0523-4041-a245-39fbee06c962)

##User Journey##

###Vault Creation###

![image](https://github.com/tranquanghuy7198/gefion/assets/24476347/8160128c-91c4-458d-89fc-eaaddb9ff6af)
![image](https://github.com/tranquanghuy7198/gefion/assets/24476347/212e3162-e418-4865-862a-2982af66671e)
![image](https://github.com/tranquanghuy7198/gefion/assets/24476347/fe4fa5d9-9c78-48fa-bfb5-5a737e229b5d)
![image](https://github.com/tranquanghuy7198/gefion/assets/24476347/b24644a1-8078-490c-bc83-d13622ef0bc7)
![image](https://github.com/tranquanghuy7198/gefion/assets/24476347/92f5b338-f26f-46b3-8235-ee353f1faf26)
![image](https://github.com/tranquanghuy7198/gefion/assets/24476347/82c22ec0-23a4-4d41-813f-42328871e6bb)





## Project structure

### Solidity contracts

This project contains 3 contracts, which are placed in the `contracts/core` folder.

* `GefionFactory.sol`: This is the factory contract which is used to manage Gefion Vaults. The vault owner can create his own vault using the `GefionFactory` contract.
* `GefionVault.sol`: This is the core smart contract of Gefion System. The investors can invest money to their preferred vaults and receive liquidity tokens, which can be used to redeem to get capitals and interests later. The traders can borrow the money from the vault to invest and repay to the vaults later.
* `GefionRouter.sol`: This is the router contract which makes it easier for users (investors and traders) to interact with Gefion System. Users can interact with a single router contract instead of having to interact with many vault contracts.

### Deployment scripts

These is a JavaScript script which is used to deploy the above contracts to blockchain.

> scripts/deploy/gefion.js

After each deployment, the address of the deployed contract is automatically written to the `deploy.json` file, which is placed in the root folder of the project.

### Testing scripts

> test/gefion.js

This is the JS file used to test Gefion smart contracts. It contains 11 test-cases which simulate the activities of investing, borrowing, repaying and redeeming in Gefion vaults.

### Tools

This project uses Hardhat as a main tool to test and deploy smart contracts.

```sh
# Test Gefion contracts
$ npx hardhat test {path-to-test-file}

# Deploy and set up Gefion contracts
$ npx hardhat run {path-to-scripts} --network {network-name}
```

### Deployments

In this project, those contracts are deployed to Binance Smart Chain Testnet, whose Chain ID is 97.
