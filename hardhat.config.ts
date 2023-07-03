import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "hardhat-deploy"
import "dotenv/config"

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    pulsechain: {
      chainId: 369,
      url: process.env.PULSECHAIN_RPC,
      verify: {
        etherscan: {
          apiKey: "abc",
          apiUrl: "https://scan.pulsechain.com",
        }
      },
      accounts: [process.env.PRIVATE_KEY!]
    }
  },
  namedAccounts: {
    deployer: 0
  }
};

export default config;
