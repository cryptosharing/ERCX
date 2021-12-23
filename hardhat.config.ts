import '@nomiclabs/hardhat-waffle';
import 'hardhat-typechain';

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: 'hardhat',
};
