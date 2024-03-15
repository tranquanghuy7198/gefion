require("@nomiclabs/hardhat-ethers");

const hre = require("hardhat");
const { expect } = require("chai");
const { soliditySha3 } = require("web3-utils");
const VAULT = "GefionVault";
const ROUTER = "GefionRouter";
const FACTORY = "GefionFactory";
const USDT = "USDT";

before("Deploy contracts", async () => {
  // Prepare parameters
  const [deployer, vaultOwner, trader, investor1, investor2] = await hre.ethers.getSigners();
  this.deployer = deployer;
  this.vaultOwner = vaultOwner;
  this.trader = trader;
  this.investor1 = investor1;
  this.investor2 = investor2;

  // Deploy Factory
  this.factory = await hre.ethers.getContractFactory(FACTORY);
  this.factoryContract = await this.factory.deploy();
  await this.factoryContract.deployed();

  // Deploy Router
  this.routerFactory = await hre.ethers.getContractFactory(ROUTER);
  this.routerContract = await this.routerFactory.deploy(this.factoryContract.address);
  await this.routerContract.deployed();

  // Deploy USDT
  this.usdtFactory = await hre.ethers.getContractFactory(USDT);
  this.usdtContract = await this.usdtFactory.deploy();
  await this.usdtContract.deployed();

  // Prepare vault factory
  this.vaultFactory = await hre.ethers.getContractFactory(VAULT);
});

describe("Test contracts", () => {
  it("Deployer sets up", async () => {
    await this.usdtFactory
      .connect(this.deployer)
      .attach(this.usdtContract.address)
      .mint(this.trader.address, hre.ethers.utils.parseEther("1000"));
    await this.usdtFactory
      .connect(this.deployer)
      .attach(this.usdtContract.address)
      .mint(this.investor1.address, hre.ethers.utils.parseEther("1000"));
    await this.usdtFactory
      .connect(this.deployer)
      .attach(this.usdtContract.address)
      .mint(this.investor2.address, hre.ethers.utils.parseEther("1000"));
    await this.factory
      .connect(this.deployer)
      .attach(this.factoryContract.address)
      .setRouter(this.routerContract.address);
    const factoryAddress = await this.routerContract.factory();
    const routerAddress = await this.factoryContract.router();
    expect(factoryAddress).to.equal(this.factoryContract.address);
    expect(routerAddress).to.equal(this.routerContract.address);
  });

  it("Vault owner creates a new vault and adds traders", async () => {
    const tx = await this.factory
      .connect(this.vaultOwner)
      .attach(this.factoryContract.address)
      .createVault(
        this.usdtContract.address,
        "Tether USD Liquidity",
        "USDT-LP",
        7500
      );
    const events = (await tx.wait()).events;
    this.vaultContract = this.vaultFactory.attach(events[0]?.args?.vault);
    await this.routerFactory
      .connect(this.vaultOwner)
      .attach(this.routerContract.address)
      .addTraders(this.usdtContract.address, [this.trader.address]);
  });

  it("Investor invests 20 USDT", async () => {
    await this.usdtFactory
      .connect(this.investor1)
      .attach(this.usdtContract.address)
      .approve(this.vaultContract.address, hre.ethers.utils.parseEther("20"));
    await this.routerFactory
      .connect(this.investor1)
      .attach(this.routerContract.address)
      .invest(
        this.vaultOwner.address,
        this.usdtContract.address,
        hre.ethers.utils.parseEther("20")
      );
    const investorUsdtBalance = await this.usdtContract.balanceOf(this.investor1.address);
    const vaultUsdtBalance = await this.usdtContract.balanceOf(this.vaultContract.address);
    const investorLiquidityBalance = await this.vaultContract.balanceOf(this.investor1.address);
    expect(investorUsdtBalance?.toString()).to.equal(hre.ethers.utils.parseEther("980"));
    expect(vaultUsdtBalance?.toString()).to.equal(hre.ethers.utils.parseEther("20"));
    expect(investorLiquidityBalance?.toString()).to.equal(hre.ethers.utils.parseEther("20"));
  });

  it("Trader borrows 12 USDT", async () => {
    const tx = await this.routerFactory
      .connect(this.trader)
      .attach(this.routerContract.address)
      .borrow(
        this.vaultOwner.address,
        this.usdtContract.address,
        hre.ethers.utils.parseEther("12")
      );
    // const events = (await tx.wait()).events;
    // this.investmentId = events[0]?.args?.investmentId;
    // console.log("XXX", events, this.investmentId);
    const vaultUsdtBalance = await this.usdtContract.balanceOf(this.vaultContract.address);
    const receivable = await this.vaultContract.receivable(hre.ethers.utils.parseEther("20"));
    expect(vaultUsdtBalance.toString()).to.equal(hre.ethers.utils.parseEther("8"));
    expect(receivable.toString()).to.equal(hre.ethers.utils.parseEther("8"));
  });

  it("Trader repays 16 USDT", async () => {
    const traderInvestmentHistory = await this.vaultContract.traderInvestmentHistory(this.trader.address);
    await this.usdtFactory
      .connect(this.trader)
      .attach(this.usdtContract.address)
      .approve(this.vaultContract.address, hre.ethers.utils.parseEther("16"));
    await this.routerFactory
      .connect(this.trader)
      .attach(this.routerContract.address)
      .repay(
        this.vaultOwner.address,
        this.usdtContract.address,
        traderInvestmentHistory[0]?.id,
        hre.ethers.utils.parseEther("16")
      );
    const vaultUsdtBalance = await this.usdtContract.balanceOf(this.vaultContract.address);
    expect(vaultUsdtBalance.toString()).to.equal(hre.ethers.utils.parseEther("21"));
  });

  it("Investor redeems all liquidity", async () => {
    await this.routerFactory
      .connect(this.investor1)
      .attach(this.routerContract.address)
      .redeem(
        this.vaultOwner.address,
        this.usdtContract.address,
        hre.ethers.utils.parseEther("20")
      );
    const investorUsdtBalance = await this.usdtContract.balanceOf(this.investor1.address);
    expect(investorUsdtBalance.toString()).to.equal(hre.ethers.utils.parseEther("1001"));
  });
});