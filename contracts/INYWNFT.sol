// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface INYWNFT{
  function getCreator(uint256 tokenId) external view returns(address);
}