// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;

import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router01.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IERC20.sol";
import "./libraries/UniswapV2Library.sol";
import "./libraries/SafeERC20.sol";
import "hardhat/console.sol";

contract FlashLoan 
{
    using SafeERC20 for IERC20; 
    // optimization(save gas)
        //-> we made all variable constant   -> store as a constant, it will only need be calculated once during compilation.
        //-> private
    address private constant PANCAKE_FACTORY =0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; // Factory and Routing Addresses
    address private constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;// Token Addresses
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant CROX = 0x2c094F5A7D1146BB93850f629501eB749f6Ed491;
    address private constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    uint256 private deadline = block.timestamp + 1 days;


    uint256 private constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
//  uint256 private constant MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
//  uint256 private constant MAX_INT = 2**256 - 1;

    //  There’s a variety of reasons you might want to know the maximum possible integer in solidity. 
    //  One common use case is to approve a contract to transfer your tokens on your behalf:
    //  tokenContract.approve(exchangeContract, MAX_INT, { from: me })
    //  Here I tell the token contract that the exchange contract is allowed to transfer all my tokens.


    function checkResult(uint _repayAmount,uint _acquiredCoin) pure private returns(bool)
    {
        return _acquiredCoin>_repayAmount;
    }
    
    function getBalanceOfToken(address _address) public view returns (uint256)              // GET CONTRACT BALANCE
    {
        return IERC20(_address).balanceOf(address(this));
    }


    function placeTrade(address _fromToken,address _toToken,uint _amountIn) private returns(uint)
    {
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(_fromToken,_toToken);     // find/accessing liquidity pool of BUSD and WBNB
        require(pair != address(0), "Pool does not exist");

        // Calculate Amount Out
        address[] memory path_array = new address[](2); //token address store
        path_array[0] = _fromToken;
        path_array[1] = _toToken;

        //estimated value
        uint256 amountRequired = IUniswapV2Router01(PANCAKE_ROUTER).getAmountsOut(_amountIn, path_array)[1];   //[1]->1st idenex of return value of this function  == amount1 of token1 we get when we swap with amount0 of token0     |  call-> PancakeLibrary contract (check on github)
        //exact value
        uint256 amountReceived = IUniswapV2Router01(PANCAKE_ROUTER).swapExactTokensForTokens(_amountIn, amountRequired, path_array,address(this),deadline )[1];

        require(amountReceived > 0, "Shit, Transaction Abort ");  

        return amountReceived;
    }



    // handle tokens from liquidity pool
    //      call -> pancakecall 
    //                  -> settelmenet (fee for Flash loan,kitna vapas dena hai ,kitna apne pass rakna hai   like operations)
    //                  -> call trade 
    //                          -> trading in Arbitrage
    function initateArbitrage(address Token_Borrowed,uint amount_of_Borrowed) external      // input = Token_Borrowed = BUSD 
    {

        IERC20(BUSD).safeApprove(address(PANCAKE_ROUTER),MAX_INT);                       //approve a PANCAKE_ROUTER contract to transfer your BUSD tokens on your behalf ,MAX_INT using because we are giving 100%  authority to contract
        IERC20(CROX).safeApprove(address(PANCAKE_ROUTER),MAX_INT);                      //using SafeERC20 for IERC20;
        IERC20(CAKE).safeApprove(address(PANCAKE_ROUTER),MAX_INT);
         
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(Token_Borrowed,WBNB); // find/accessing liquidity pool of BUSD and WBNB
        require(pair!=address(0),"Pool does not exist");
         
        
        address token0 = IUniswapV2Pair(pair).token0();                                         //WBNB get tokens address from  liquidity pool  
        address token1 = IUniswapV2Pair(pair).token1();                                        //BUSD 
        
        uint amount0Out = Token_Borrowed == token0  ?  amount_of_Borrowed:0;                 // = 0
        uint amount1Out = Token_Borrowed == token1  ?  amount_of_Borrowed:0;                //= amount_of_Borrowed 
         
        bytes memory data = abi.encode(Token_Borrowed,amount_of_Borrowed,msg.sender);     // Flash Swap Docs  ->  Triggering a Flash Swap (https://docs.uniswap.org/contracts/v2/guides/smart-contract-integration/using-flash-swaps)

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);         // address(this) == address of this contract
        // transfer BUSD to our contract (address(this))
        // use of pair  ->     In IUniswapV2Pair contract(Github)     ->    needed token0,token1 address (get using pair)
        // swap function will call pancakeCall function -> inbuild -> check in contract(Github)
    }



    function pancakeCall(address _sender,uint256 amount0,uint256 amount1,bytes calldata _data) external  //must have same name of func
    {
//_____________________checking_________________________________________________________________________________________________________________        
        address token0 = IUniswapV2Pair(msg.sender).token0();                        //msg.sender = pair = liquidity pool address
        address token1 = IUniswapV2Pair(msg.sender).token1();                        //accessing token1 address
        
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(token0,token1);
        require(msg.sender == pair, "The sender needs to match the pair");
        require(_sender == address(this), "Sender should match the contract");
//___________________________________________________________________________________________________________________________
       
        (address Token_Borrowed, uint256 amount_of_Borrowed, address myAddress) = abi.decode(_data,(address, uint256, address));    // // Decode data for calculating the repayment
  
        uint256 fee = ((amount_of_Borrowed * 3) / 997) + 1;                         // Calculate the amount to repay at the end
        uint256 repayAmount = amount_of_Borrowed + fee;

        
        uint256 loanAmount =    amount0 > 0     ?   amount0 :   amount1;            // Assign loan amount

        // Triangular ARBITRAGE
        uint256 trade1Coin = placeTrade(BUSD, CROX, loanAmount);                    // BUSD -> CROX
        uint256 trade2Coin = placeTrade(CROX, CAKE, trade1Coin);                    // CROX -> CAKE
        uint256 trade3Coin = placeTrade(CAKE, BUSD, trade2Coin);                    // CAKE -> BUSD


        bool profCheck = checkResult(repayAmount, trade3Coin);                      // Check Profitability
        require(profCheck, "Arbitrage not profitable");

        
        IERC20 otherToken = IERC20(BUSD);                                           // Pay Myself
        otherToken.transfer(myAddress, trade3Coin - repayAmount);

        
        IERC20(Token_Borrowed).transfer(pair, repayAmount);                        // Pay Loan Back
    }



}
