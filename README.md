# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```



Pancakeswap use UniswapV2 (Pancakeswap made using fork of Uniswap) -> That why we use interfaces & libraries of Uniswap
edit harhat.config.js file
__________________________________Interfaces used________________________________________________________________

IUniswapV2Factory 
    -> it deals with liquidity pool

IERC20
    -> transferring tokens
    -> querying the balance of an address
    -> approving third parties to spend tokens on your behalf(allowance)

IUniswapV2Pair 
    -> get the address of tokens in liquidity pool

IUniswapV2Router01(version 1)    &    IUniswapV2Router02(version 2)
    -> Responsible for swaps and providing liquidity in Uniswap Protocol

__________________________________Libraries used________________________________________________________________

Address
    ->Returns true if 
        ->`address` is a contract.
    ->Retruns False if(unsafe) 
        -> an EOA
        -> an address where a contract lived, but was destroyed
        -> a contract in construction
        -> an address where a contract will be created

SafeERC20
    -> provide safe methods for interacting with ERC20 token(no Vulnerabilies)

SafeMath
    -> prevent overflow & underflow

UniswapV2Library
    -> Return Current reserve of Uniswap V2 pair function 
    -> getReserves(address factory,address tokenA,address tokenB)
        
        
        

