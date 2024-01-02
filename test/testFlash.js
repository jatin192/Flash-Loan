// you need to impersonate account availabe on mainnet  ->  we use the mainnet accounts to check our smart contract

let {expect,assert} = require("chai");
let {ethers,waffle} = require("hardhat");
let {fundContract} = require("../utils/utilities");
let {abi}= require("../artifacts/contracts/interfaces/IERC20.sol/IERC20.json");
let provider = waffle.provider;


describe("Flash_Loan",()=>
{
    let Flash_Loan_i,borrow_amount,fund_amount_human,fund_amount,tx_arbitrage,WHALE_balance,decimal;
    decimal =18;
    //BUSD_WHALE -> provide fund to smart contract
    let BUSD_WHALE ="0xf977814e90da44bfa03b6295a0616a897441acec"; // Mainnet account  https://www.coincarp.com/currencies/binanceusd/richlist/      , WHALE means these account have large amount on Token
    let BUSD = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
    let CROX = "0x2c094F5A7D1146BB93850f629501eB749f6Ed491";
    let CAKE = "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82";


    let busd_token_i = new ethers.Contract(BUSD,abi,provider);  //busd token instance



    before(async()=>
    {
        let j= await ethers.getContractFactory("Flash_Loan");
        Flash_Loan_i = await j.deploy(); // smart contract instance
        await Flash_Loan_i.deployed();


        WHALE_balance = await provider.getBalance(BUSD_WHALE);


        let borrow_amount_human ="200";
        borrow_amount = ethers.utils.parseUnits(borrow_amount_human,decimal);
        console.log("borrow_amount = ",borrow_amount);


        fund_amount_human ="1";
        fund_amount = ethers.utils.parseUnits(fund_amount_human,decimal);
        console.log("fund_amount = ",fund_amount);


        await fundContract(busd_token_i,  BUSD_WHALE,  Flash_Loan_i.address,  fund_amount_human);
        //                  (contract,       sender,          recepient,          amount)
    })
    it("cheking BUSD WHALE Mainet account",async()=>{
        console.log("WHALE_balance =",WHALE_balance);
        expect(WHALE_balance).not.equal("0");
    })
    it("Ensure Contract is funded",async()=>
    {
        let  flash_loan_balance = await Flash_Loan_i.getBalanceOfToken(BUSD);
        // console.log("typeof =", typeof(flash_loan_balance)," ",typeof(fund_amount));
        expect(flash_loan_balance).equal(fund_amount);
    })
    it("EXECUTE Arbitrage",async()=>
    {
        tx_arbitrage = await Flash_Loan_i.initateArbitrage(BUSD,borrow_amount);
        console.log(
            "trade1Coin = ",await Flash_Loan_i.trade1Coin(),
            "trade2Coin = ",await Flash_Loan_i.trade2Coin(),
            "trade3Coin = ",await Flash_Loan_i.trade3Coin()
        )
        // assert(tx_arbitrage);
    })
    it("Printing",async()=>
    {
        console.log(
            "trade1Coin = ",await Flash_Loan_i.trade1Coin(),
            "trade2Coin = ",await Flash_Loan_i.trade2Coin(),
            "trade3Coin = ",await Flash_Loan_i.trade3Coin()
        )
    })
    
})
