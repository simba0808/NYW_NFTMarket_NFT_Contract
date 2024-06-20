// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the

import { ethers } from 'hardhat';

async function main() {
  const nywNftContract = await ethers.deployContract('NYWNFT');
  await nywNftContract.waitForDeployment();
  const nywNftContractAddress = await nywNftContract.getAddress();
  console.log('NYWNFT Contract is deployed!', nywNftContractAddress);

  const nywMarketContract = await ethers.deployContract('NYWMarket', [
    nywNftContractAddress,
  ]);
  await nywMarketContract.waitForDeployment();
  const nywMarketContractAddress = await nywMarketContract.getAddress();
  console.log('NYWMarket Contract is deployed', nywMarketContractAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
