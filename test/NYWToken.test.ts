import { expect } from 'chai';
import { ethers } from 'hardhat';

let accounts: any;
let nywTokenContract: any;
let nywTokenContractAddress: any;

describe('NYWToken Contract', function () {
  before('Deploy NYWToken Contract:', async function () {
    accounts = await ethers.getSigners();
    nywTokenContract = await ethers.deployContract('NYWToken');
    nywTokenContractAddress = await nywTokenContract.getAddress();
    console.log('Token Contract is deployed successfully.');
    console.log('Token Contract Address: ', nywTokenContractAddress);
  });

  it('Deployment should assign the total supply of tokens to the owner', async function () {
    const ownerBalance = await nywTokenContract.balanceOf(accounts[0].address);
    expect(await nywTokenContract.totalSupply()).to.equal(ownerBalance);
  });

  it('Should return the correct name and symbol', async () => {
    expect(await nywTokenContract.name()).to.equal('NYW Token');
    expect(await nywTokenContract.symbol()).to.equal('NYWT');
  });
});
