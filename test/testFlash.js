// you need to impersonate account availabe on mainnet  ->  we use the mainnet accounts to check our smart contract

let {expect,assert} = require("chai");
let {ethers,waffle} = require("hardhat");
let {fund_Contract} = require("../utils/utilities");
let {abi}= require("../artifacts/contracts/interfaces/IERC20.sol/IERC20.json");
let provider = waffle.provider;

describe("Flash_Loan",()=>
{
    let flash_loan,borrow_amount,initial_funding_human,tx_arbitrage,decimal;
    decimal =18;
    //BUSD_WHALE -> provide fund to smart contract
    let BUSD_WHALE ="0x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503"; // Mainnet account  https://www.coincarp.com/currencies/binanceusd/richlist/      , WHALE means these account have large amount on Token
    let BUSD = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
    let CROX = "0x2c094F5A7D1146BB93850f629501eB749f6Ed491";
    let CAKE = "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82";

    let busd_contract_instance = new ethers.Contract(BUSD,abi,provider);
    beforeEach(async()=>
    {
        let WHALE_balance = await provider.getBalance(BUSD_WHALE);
        console.log("WHALE_balance =",WHALE_balance);
        expect(WHALE_balance).not.equal("0");
    })
    it("Testing",()=>{})
})

