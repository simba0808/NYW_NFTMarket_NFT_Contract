const { expect } = require('chai');
import { ethers } from 'hardhat';

describe('NYW Market Contract', function () {
  let nywNftContract: any;
  let nywNftContractAddress: string;
  let nywMarketContract: any;
  let nywMarketContractAddress: string;
  let accounts: any;

  before(async function () {
    accounts = await ethers.getSigners();

    nywNftContract = await ethers.deployContract('NYWNFT');
    await nywNftContract.waitForDeployment();
    nywNftContractAddress = await nywNftContract.getAddress();
    console.log('NYW Contract is deployed successfully.');
    console.log('NYW Contract Address: ', nywNftContractAddress);

    nywMarketContract = await ethers.deployContract('NYWMarket', [
      nywNftContractAddress,
    ]);
    nywMarketContractAddress = await nywMarketContract.getAddress();
    console.log('NYWMarket Contract is deployed successfully.');
    console.log('NYWMarket Contract Address: ', nywMarketContractAddress);
  });

  const buyPrice = ethers.parseEther('1');

  it('Should be listed NFT with correct parameters', async () => {
    const createTx = await nywNftContract
      .connect(accounts[0])
      .create('test_uri_1', 10);
    await createTx.wait();

    // const nftOwner = await nywNftContract.ownerOf(1);
    // console.log('Owner of NFT[1]: ', nftOwner);
    // console.log('accounts[0]: ', accounts[0].address);

    await nywNftContract
      .connect(accounts[0])
      .approve(nywMarketContractAddress, 1);

    await expect(nywMarketContract.connect(accounts[0]).listNft(1, buyPrice))
      .to.emit(nywMarketContract, 'NYW__NFTListed')
      .withArgs(1);
  });

  // it('Should be deList NFT with correct parameters', async () => {
  //   await expect(nywMarketContract.connect(accounts[0]).delistNft(1))
  //     .to.emit(nywMarketContract, 'NYW__NFTDelisted')
  //     .withArgs(1);
  // });

  it('Should buy NFT with correct parameters', async () => {
    await expect(
      nywMarketContract.connect(accounts[1]).buyNft(1, { value: buyPrice })
    )
      .to.emit(nywMarketContract, 'NYW__NFTSold')
      .withArgs(1, accounts[1], buyPrice);
  });

  it('withdraw all marketing fee', async () => {
    await expect(nywMarketContract.connect(accounts[0]).withdraw())
      .to.emit(nywMarketContract, 'NYW__withdraw')
      .withArgs(ethers.parseEther('0.025'));
  });
});
