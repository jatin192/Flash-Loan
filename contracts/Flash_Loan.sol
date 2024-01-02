// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;


// _____________________________________Interfaces________________________________________________________________________________________________________________________________

// "I" stand for Interface in   IUniswapV2Factory      
import "./interfaces/IUniswapV2Factory.sol";            //     it deals with liquidity pool
import "./interfaces/IUniswapV2Pair.sol";              //      get the address of tokens in liquidity pool

import "./interfaces/IUniswapV2Router01.sol";        //     | (version 1)   Responsible for swaps and providing liquidity in Uniswap Protocol
import "./interfaces/IUniswapV2Router02.sol";       //      | (version 2)   

import "./interfaces/IERC20.sol";                 //     | transferring tokens
                                                 //      | querying the balance of an address
                                                //       | approving third parties to spend tokens on your behalf(allowance)





// _____________________________________Libraries________________________________________________________________________________________________________________________________

import "./libraries/UniswapV2Library.sol";  // Return Current reserve of Uniswap V2 pair function 
                                           //  getReserves(address factory,address tokenA,address tokenB)

import "./libraries/SafeERC20.sol";      //   provide safe methods for interacting with ERC20 token(no Vulnerabilies)    

import "hardhat/console.sol";

//SafeERC20 -> import -> use Address.sol Library ->  isContract(address account)
// Address
//     ->Returns true if 
//         ->`address` is a contract.
//     ->Retruns False if(unsafe) 
//         -> an EOA
//         -> an address where a contract lived, but was destroyed
//         -> a contract in construction
//         -> an address where a contract will be created


// SafeMath
//     -> prevent overflow & underflow








   
// _____________________________________Contract________________________________________________________________________________________________________________________________

contract Flash_Loan 
{
    using SafeERC20 for IERC20; 

//_____________________________________Variables________________________________________________________________________________________________________________________________

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








// _____________________________________Functions________________________________________________________________________________________________________________________________
    //initateArbitrage   -> pancakeCall (inbuild) ->  placeTrade

    function checkResult(uint _repayAmount,uint _acquiredCoin) pure private returns(bool)      { return _acquiredCoin>_repayAmount;}
    function getBalanceOfToken(address _address) public view returns (uint256)                 {  return IERC20(_address).balanceOf(address(this));  }      // GET CONTRACT BALANCE

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

        //_________________________Approval____________________________________________________________________________________________________________________________________________
        IERC20(BUSD).safeApprove(address(PANCAKE_ROUTER),MAX_INT);                       //approve a PANCAKE_ROUTER contract to transfer your BUSD tokens on your behalf ,MAX_INT using because we are giving 100%  authority to contract
        IERC20(CROX).safeApprove(address(PANCAKE_ROUTER),MAX_INT);                      //using SafeERC20 for IERC20;
        IERC20(CAKE).safeApprove(address(PANCAKE_ROUTER),MAX_INT);
         
        //_________________________Liquidity Pool_____________________________________________________________________________________________________________________                  
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(Token_Borrowed,WBNB); // find/accessing liquidity pool of BUSD and WBNB   -> Bsc scan website -> Read contract -> call getPair() function 
        require(pair!=address(0),"Pool does not exist");
         
        //________________________transfer Token_Borrowed to address(this)_________________________________________________________________________________________         
        // Token0,1 = (WBNB,BUSE) ? or (BUSE,WBNB) ?
        address token0 = IUniswapV2Pair(pair).token0();                                         //WBNB get tokens address from  liquidity pool  
        address token1 = IUniswapV2Pair(pair).token1();                                        //BUSD 
        
        uint amount0Out = Token_Borrowed == token0  ?  amount_of_Borrowed:0;                 // = 0
        uint amount1Out = Token_Borrowed == token1  ?  amount_of_Borrowed:0;                //= amount_of_Borrowed 
         
        bytes memory data = abi.encode(Token_Borrowed,amount_of_Borrowed,msg.sender);     // Flash Swap Docs  ->  Triggering a Flash Swap (https://docs.uniswap.org/contracts/v2/guides/smart-contract-integration/using-flash-swaps)

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);        // transfer BUSD to our contract (address(this))       
        // use of pair  ->     In IUniswapV2Pair contract(Github)     ->    needed token0,token1 address (get using pair)
        // IUniswapV2Pair -> have swap function  that will call pancakeCall function -> inbuild -> check in contract(Github)
    }









     function pancakeCall(address _sender,uint256 amount0,uint256 amount1,bytes calldata _data) external  // function name must be "pancakeCall"   -> IUniswapV2Pair -> have swap function  that will call pancakeCall function -> inbuild -> check in contract(Github)
    {
        //_____________________checking for Security purpose (call my me only)_________________________________________________________________________________________________________________        
        address token0 = IUniswapV2Pair(msg.sender).token0();                        //msg.sender = pair = liquidity pool address
        address token1 = IUniswapV2Pair(msg.sender).token1();                        //accessing token1 address
        
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(token0,token1);
        require(msg.sender == pair, "The sender needs to match the pair");
        require(_sender == address(this), "Sender should match the contract");

        //___________________________________________________________________________________________________________________________
        // function swap( , , address to, bytes calldata data)
        (address Token_Borrowed, uint256 amount_of_Borrowed, address myAddress) = abi.decode(_data,(address, uint256, address));    //Decode data for calculating the repayment  
  
        uint256 fee = ((amount_of_Borrowed * 3) / 997) + 1;                         // Calculate the amount to repay at the end
        uint256 repayAmount = amount_of_Borrowed + fee;
        uint256 loanAmount =    amount0 > 0     ?   amount0 :   amount1;            // Assign loan amount
        // Triangular ARBITRAGE
        //             BUSD
        //              /\
        //             /  \
        //            /    \
        //           /      \
        //          /        \
        //         /          \
        //        /____________\
        //      CAKE          CROX
        uint256 trade1Coin = placeTrade(BUSD, CROX, loanAmount);                    // BUSD -> CROX
        uint256 trade2Coin = placeTrade(CROX, CAKE, trade1Coin);                    // CROX -> CAKE
        uint256 trade3Coin = placeTrade(CAKE, BUSD, trade2Coin);                    // CAKE -> BUSD

        bool profit_Check = checkResult(repayAmount, trade3Coin);                      // Check Profitability
        require(profit_Check, "Arbitrage not profitable");

        IERC20 otherToken = IERC20(BUSD);                                           // Pay Myself
        otherToken.transfer(myAddress, trade3Coin - repayAmount);

        IERC20(Token_Borrowed).transfer(pair, repayAmount);                        // Pay Loan Back
    }

}






















// Resources

//Github Link
//  https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/PancakeRouter.sol
//  https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/libraries/PancakeLibrary.sol
//  https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/PancakePair.sol 



// bscscan ->  search  ->  0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73   ->  Contract -> Read Contract -> call getPair(WBNB,BUSD) -> Liquidity pool 
//                                  (PANCAKE_FACTORY)

// getPair -> https://bscscan.com/address/0xca143ce32fe78f1f7019d7d551a6402fc5350c73#readContract#F6
// 
// token 0 -> https://bscscan.com/address/0x58f876857a02d6762e0101bb5c46a8c1ed44dc16#readContract#F15 
// token 1 -> https://bscscan.com/address/0x58f876857a02d6762e0101bb5c46a8c1ed44dc16#readContract#F16 