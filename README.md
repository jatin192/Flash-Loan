
#
![Screenshot from 2024-01-02 23-32-36](https://github.com/jatin192/Flash-Loan/assets/73174196/bea5f631-82de-464f-a303-5e0236f96be3)

# Installation

To run the Decentralize Decentralized File Sharing Applicatioin locally, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/jatin192/Flash-Loan.git
   ```

2. Install the required dependencies :

   ```bash
   npm install   
   ```
3. Testing :

   ```bash
   npx hardhat test
   ```  

## Resources

- [Pancake swap Interface Libraries](https://github.com/pancakeswap/pancake-swap-periphery/tree/master/contracts)
- [Uniswap Interface Libraries](https://github.com/Uniswap/v2-core/tree/master/contracts)
- [Hardhat Testing](https://hardhat.org/tutorial/testing-contracts)
- [BUSD WHALE Mainnet Accounts](https://www.coincarp.com/currencies/binanceusd/richlist/)

#

![Screenshot from 2024-01-02 23-30-36](https://github.com/jatin192/Flash-Loan/assets/73174196/563cf5b0-1de0-414a-b573-6f7a6ccf73e7)



![Screenshot from 2024-01-02 23-31-01](https://github.com/jatin192/Flash-Loan/assets/73174196/4acf8204-7d79-4470-9896-6359b5f76394)



# Contract Breakdown:

### Functions:

-  checkResult: 
Checks if the arbitrage was profitable.

-  getBalanceOfToken: 
Returns the balance of a token held by the contract.

-  placeTrade: 
Executes a token swap using PancakeSwap's router.

-  initiateArbitrage: 
Triggers the arbitrage process by borrowing tokens and calling pancakeCall.

- pancakeCall: Handles the logic within the flash loan transaction, including:
    1. Security checks
    2. Decoding data
    3. Calculating fees and repayment
    4. Executing trades (BUSD -> CROX -> CAKE -> BUSD)
    5. Checking profitability
    6. Repaying the loan
    7. Distributing profits
    
#
## Additional Insights:

- Fees: Consider the fees involved in flash loans and trades, as they can impact profitability.
- Price Slippage: Large trades can cause price slippage, potentially reducing profits.
- Market Efficiency: Arbitrage opportunities can disappear quickly as markets adjust.
- Risks: Flash loans can be risky if not managed properly, as potential issues (e.g., failed trades) could lead to failed repayment.

        
        
        

