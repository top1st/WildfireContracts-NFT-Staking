# WildfireContracts - NFT Staking
## Overview

WildfireContracts-NFT-Staking is a smart contract suite for NFT staking, allowing users to stake their NFTs and earn rewards in return. This repository contains the necessary smart contracts for creating a decentralized NFT staking platform using the Ethereum network.

With WildfireContracts, you can integrate NFT staking capabilities into your decentralized applications (dApps), ensuring a secure and efficient staking mechanism for NFT holders.

Features
NFT Staking: Users can stake their NFTs in exchange for rewards.
Rewards System: Earn rewards in a predefined token while staking NFTs.
Flexible Contract Logic: Easy to configure for different NFT collections and reward distribution.
Secure and Efficient: Developed with security in mind to prevent exploits or theft of staked NFTs.
Requirements
Solidity: 0.8.x
Ethereum: Mainnet or testnets like Rinkeby, Goerli, or others
Node.js: 16.x or higher
Truffle or Hardhat: For deploying the smart contracts
Metamask: For interacting with the Ethereum network
Ethers.js / Web3.js: For interacting with the smart contracts on the frontend
Installation
Prerequisites

Ensure you have Node.js, Truffle (or Hardhat), and Metamask set up.

## Clone the repository
git clone https://github.com/top1st/WildfireContracts-NFT-Staking.git

# Navigate into the project directory
cd WildfireContracts-NFT-Staking

## Install dependencies
npm install
Compiling the Smart Contracts

To compile the smart contracts, use the following command:

## Using Truffle
truffle compile

Or, if using Hardhat:

## Using Hardhat
npx hardhat compile
Deploying the Contracts

To deploy the contracts on a testnet or the Ethereum mainnet, you will need to configure your truffle-config.js or hardhat.config.js file.

For example, using Truffle:

## Deploy to a testnet
truffle migrate --network rinkeby

Or using Hardhat:

## Deploy using Hardhat (to Rinkeby, for example)
npx hardhat run scripts/deploy.js --network rinkeby
Interacting with the Contract

You can interact with the deployed smart contract using Ethers.js or Web3.js. An example is provided below:

const { ethers } = require("ethers");

// Connect to the contract
const provider = new ethers.JsonRpcProvider("https://rinkeby.infura.io/v3/YOUR_INFURA_PROJECT_ID");
const wallet = new ethers.Wallet("YOUR_PRIVATE_KEY", provider);
const contractAddress = "YOUR_CONTRACT_ADDRESS";
const contractABI = [ /* ABI here */ ];

// Create a contract instance
const contract = new ethers.Contract(contractAddress, contractABI, wallet);

// Example: Staking an NFT
async function stakeNFT(nftId) {
  const tx = await contract.stakeNFT(nftId);
  console.log("Transaction:", tx);
  await tx.wait();
  console.log("NFT Staked!");
}
Frontend Integration

To integrate the contract with a frontend, use Ethers.js or Web3.js to interact with the deployed smart contract. Here’s a basic example using Ethers.js:

import { ethers } from 'ethers';

async function connectToMetaMask() {
  if (window.ethereum) {
    const provider = new ethers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(contractAddress, contractABI, signer);

    // Call contract functions (e.g., stakeNFT)
    await contract.stakeNFT(nftId);
  } else {
    alert('MetaMask is not installed!');
  }
}
Contract Details
Staking Contract

The NFT Staking Contract allows users to stake their NFTs in exchange for reward tokens. The reward can be configured based on time or NFT type. The contract handles:

Staking NFTs: Users can deposit NFTs into the contract.
Unstaking NFTs: Users can withdraw staked NFTs.
Reward Distribution: Rewards are calculated and distributed according to the staking time.
Reward Logic

Rewards are distributed based on the amount of time an NFT is staked in the contract. The logic can be customized in the contract.

Functions
stakeNFT(tokenId): Stakes an NFT by providing its token ID.
unstakeNFT(tokenId): Unstakes the NFT with the given token ID.
claimRewards(): Claims accumulated rewards for the staked NFTs.
getStakedNFTs(owner): Returns the list of NFTs staked by a specific address.
Testing
Running Tests

If you want to run tests locally, you can use the testing framework provided by Truffle or Hardhat. Ensure that your testing environment is set up (like Ganache for Truffle).

# Truffle example
truffle test

Or for Hardhat:

## Hardhat example
npx hardhat test
Security Considerations
Reentrancy Attacks: Ensure the contract is protected from reentrancy attacks by using the Checks-Effects-Interactions pattern and implementing ReentrancyGuard.
Access Control: Use proper access control mechanisms to restrict functions to authorized addresses (e.g., only the owner can change the reward rate).
Gas Optimization: The contract is optimized for low gas usage during transactions.
Contributing

We welcome contributions! If you want to contribute, follow these steps:

Fork the repository
Create a new branch (git checkout -b feature/your-feature)
Make your changes
Commit your changes (git commit -am 'Add new feature')
Push to the branch (git push origin feature/your-feature)
Create a new pull request
License

This project is licensed under the MIT License - see the LICENSE
 file for details.

Impl 0x5085C95C0E284Aa51a6a5DaE6691Ab54287AB9aD 

Proxy 0x82c66D6547482a67FE796F7202a331407887E17f
