// you need to impersinate  account available on main network ->technique where we use account that available on main net to test the smart contract 
let { expect, assert } = require("chai");
let { ethers } = require("hardhat");
let { fundContract } = require("../utils/utilities");

let {abi} = require("../artifacts/contracts/interfaces/IERC20.sol/IERC20.json");

let provider = waffle.provider; //use network waffle is vert old tool

describe("FlashLoan Contract", () => 
{
  let FLASHLOAN , BORROW_AMOUNT , FUND_AMOUNT , initialFundingHuman , txArbitrage;
  let DECIMALS = 18;
  let BUSD_WHALE = "0xf977814e90da44bfa03b6295a0616a897441acec"; // search TOP 10 BUSD account -> choose one account  ->WHALE because these account have massive amount of BUSD
  let BUSD = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
  let CAKE = "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82";
  let CROX = "0x2c094F5A7D1146BB93850f629501eB749f6Ed491";


  let busdInstance = new ethers.Contract(BUSD, abi, provider);

  beforeEach(async () => {

    // Ensure that the WHALE has a balance -> we use this account to exicute Arbitrage
    let whale_balance = await provider.getBalance(BUSD_WHALE); 
    expect(whale_balance).not.equal("0");  

    // Deploy smart contract
    let FlashLoan = await ethers.getContractFactory("FlashLoan");
    FLASHLOAN = await FlashLoan.deploy();
    await FLASHLOAN.deployed();

    let borrowAmountHuman = "1";
    BORROW_AMOUNT = ethers.utils.parseUnits(borrowAmountHuman, DECIMALS);

    initialFundingHuman = "100";
    FUND_AMOUNT = ethers.utils.parseUnits(initialFundingHuman, DECIMALS);

    // Fund our Contract - FOR TESTING ONLY
    await fundContract(
      busdInstance,
      BUSD_WHALE,
      FLASHLOAN.address,
      initialFundingHuman
    );
  });

  describe("Arbitrage Execution", () => {
    it("ensures the contract is funded", async () => {
      let flashLoanBalance = await FLASHLOAN.getBalanceOfToken(
        BUSD
      );

      let flashSwapBalanceHuman = ethers.utils.formatUnits(
        flashLoanBalance,
        DECIMALS
      );
      expect(Number(flashSwapBalanceHuman)).equal(Number(initialFundingHuman));
    });

    it("executes the arbitrage", async () => {
      txArbitrage = await FLASHLOAN.initateArbitrage(
        BUSD,
        BORROW_AMOUNT
      );

      assert(txArbitrage);

      // Print balances
      let contractBalanceBUSD = await FLASHLOAN.getBalanceOfToken(BUSD);
      let formattedBalBUSD = Number(
        ethers.utils.formatUnits(contractBalanceBUSD, DECIMALS)
      );
      console.log("Balance of BUSD: " + formattedBalBUSD);

      let contractBalanceCROX = await FLASHLOAN.getBalanceOfToken(CROX);
      let formattedBalCROX = Number(
        ethers.utils.formatUnits(contractBalanceCROX, DECIMALS)
      );
      console.log("Balance of CROX: " + formattedBalCROX);

      let contractBalanceCAKE = await FLASHLOAN.getBalanceOfToken(CAKE);
      let formattedBalCAKE = Number(
        ethers.utils.formatUnits(contractBalanceCAKE, DECIMALS)
      );
      console.log("Balance of CAKE: " + formattedBalCAKE);
    });
  });
});