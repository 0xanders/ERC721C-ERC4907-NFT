import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

const solidity = {
  compilers: [
    {
      version: '0.8.9',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  ],
  overrides: {},
}

const config: HardhatUserConfig = {
  solidity: solidity,
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 1338,
      throwOnTransactionFailures: true,
      allowUnlimitedContractSize: true,
      saveDeployments: true,
    },
  },

};

export default config;
