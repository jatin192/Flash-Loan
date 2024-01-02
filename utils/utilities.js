const { network, ethers } = require("hardhat");


// sender    = WHALE Account
// recepient = address(this) = Flash_Loan contract address 

// Write acces on Blockchain -> Temperary Control on Whale account  -> transfer token from Whale account to  Flash_Loan contrac 

const fundToken = async (contract, sender, recepient, amount) =>     // fund erc20 token to the contract
{
  const FUND_AMOUNT = ethers.utils.parseUnits(amount, 18);
  const whale = await ethers.getSigner(sender);                    // getSigner -> Write acces -> Temperary Control on Whale account            
  const contractSigner = contract.connect(whale);                 // Temperary Control -> Private Key of Whale
  await contractSigner.transfer(recepient, FUND_AMOUNT);         //  Private Key -> transfer 
};

const fundContract = async (contract, sender, recepient, amount) =>        
{
  await network.provider.request({method: "hardhat_impersonateAccount",params: [sender]});
  await fundToken(contract, sender, recepient, amount);          // fund baseToken to the contract
  await network.provider.request({
    method: "hardhat_stopImpersonatingAccount",
    params: [sender],
  });
};

module.exports = {
    fundContract: fundContract,
};