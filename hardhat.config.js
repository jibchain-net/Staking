require('hardhat-deploy');
require('hardhat-deploy-ethers');
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-contract-sizer");
require("@nomiclabs/hardhat-truffle5");
require("hardhat-gas-reporter");
require("@nomicfoundation/hardhat-chai-matchers");
// require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    version: "0.8.20",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: "0x4Fbd49c841c2f891b8e04B887B9C5035BE7c7209",
    },
    rewardWallet: {
      default: 1,
    },
    feeCollector: {
      default: 2,
    }
  },
  networks: {
    jbc: {
      url: "https://rpc-l1.jibchain.net",
      chainId: 8899,
      accounts: [process.env.PRIVATE_KEY],
      live: true,
      saveDeployments: true,
      tags: ["production"],
    },
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      jbc: 'abc'
    },
    customChains: [
      {
        network: "jbc",
        chainId: 8899,
        urls: {
          apiURL: "https://exp-l1.jibchain.net/api",
          browserURL: "https://exp-l1.jibchain.net/"
        }
      }
    ]
  },
  abiExporter: {
    path: "./abis",
    clear: true,
    flat: true,
    only: ["JBCFarm:$"],
    spacing: 2,
    pretty: true,
  },
};
