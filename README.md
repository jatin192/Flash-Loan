
![Screenshot from 2024-01-02 23-32-36](https://github.com/jatin192/Flash-Loan/assets/73174196/bea5f631-82de-464f-a303-5e0236f96be3)


![Screenshot from 2024-01-02 23-30-36](https://github.com/jatin192/Flash-Loan/assets/73174196/563cf5b0-1de0-414a-b573-6f7a6ccf73e7)



![Screenshot from 2024-01-02 23-31-01](https://github.com/jatin192/Flash-Loan/assets/73174196/4acf8204-7d79-4470-9896-6359b5f76394)




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

## Acknowledgements

Decentralize File Sharing Project is built using the following technologies:

- [Pinata](https://www.pinata.cloud/) - Pinata is an IPFS pinning service that makes IPFS easy for creators
- [Hardhat](https://hardhat.org/) - Hardhat is a development environment for Ethereum software
- [Solidity](https://docs.soliditylang.org/) - The smart contract programming language for Ethereum.
- [Metamask](https://metamask.io/)  - MetaMask is a software cryptocurrency wallet used to interact with the Ethereum blockchain.
- [React](https://react.dev/) -React is used for building interactive user interfaces and web applications quickly and efficiently.






## Key Components:


- Flash Loans:
A feature in DeFi that allows borrowing large amounts of assets for a short duration (within the same transaction) without collateral.

- Arbitrage: 
The practice of exploiting price differences between markets for profit.

-  PancakeSwap: 
A decentralized exchange (DEX) on the Binance Smart Chain (BSC).

-  Solidity: 
The programming language used to write smart contracts on Ethereum and BSC.

# Contract Breakdown:

## Variables:

## Functions:

-  checkResult: 
Checks if the arbitrage was profitable.

-  getBalanceOfToken: 
Returns the balance of a token held by the contract.

-  placeTrade: 
Executes a token swap using PancakeSwap's router.

-  initiateArbitrage: 
Triggers the arbitrage process by borrowing tokens and calling pancakeCall.

#### pancakeCall: Handles the logic within the flash loan transaction, including:
    Security checks
    
    Decoding data
    
    Calculating fees and repayment
    
    Executing trades (BUSD -> CROX -> CAKE -> BUSD)
    
    Checking profitability
    
    Repaying the loan
    
    Distributing profits
    
#
## Key Points:
-  The contract aims to exploit price differences between BUSD, CROX, and CAKE on PancakeSwap for arbitrage profits.
- It uses flash loans to borrow BUSD without collateral, executes trades, and repays the loan within a single transaction.
- Security checks are implemented to prevent unauthorized actions.
- Profitability is checked before repaying the loan and distributing profits.
#
## Additional Insights:

- Fees: Consider the fees involved in flash loans and trades, as they can impact profitability.
- Price Slippage: Large trades can cause price slippage, potentially reducing profits.
- Market Efficiency: Arbitrage opportunities can disappear quickly as markets adjust.
- Risks: Flash loans can be risky if not managed properly, as potential issues (e.g., failed trades) could lead to failed repayment.

        
        
        

