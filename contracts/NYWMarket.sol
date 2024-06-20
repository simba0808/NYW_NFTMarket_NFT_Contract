// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./INYWNFT.sol";

contract NYWMarket {
  struct NFTMarketItem {
      uint256 nftId;
      uint256 price;
      uint256 royalty;
      address seller;
      address creator;
      bool sold;
  }

  IERC721 public nftContract;
  address public nftContractAddress;
  uint256 public _nftMarketListIds;
  uint256 public _nftSolds;
  uint256 public platformFee = 25;
  uint256 public deno = 1000;
  address payable owner;
  NFTMarketItem[] public listedNFTs;
  mapping(uint256 => uint256) tokenIdToListId;
  mapping(uint256 => bool) isExist;

  constructor(address _nftContractAddress) {
      owner = payable(msg.sender);
      nftContract = IERC721(_nftContractAddress);
      nftContractAddress = _nftContractAddress;
  }

  //-----------------------------------------------------------------------
  // EVENTS
  //-----------------------------------------------------------------------

  event NYW__NFTListed(uint256 indexed tokenId);

  event NYW__NFTDelisted(uint256 indexed tokenId);

  event NYW__NFTSold(uint256 tokenId, address buyer, uint256 price);

  event NYW__withdraw(uint256 value);

  //-----------------------------------------------------------------------
  // ERRORS
  //-----------------------------------------------------------------------

  error NYW__OnlyTokenOwner(uint256 tokenId);

  // ************************ //
  //      Main Functions      //
  // ************************ //

  // * List Nft in the marketplace * //
  function listNft(uint256 tokenId, uint256 price, uint256 royalty) external {
    require(isExist[tokenId] == false, "invalid tokenId");
    require(
      royalty >= 0 && royalty <= 30,
      "Royalty should be between 0 to 30"
    );
    require(
      msg.sender == nftContract.ownerOf(tokenId),
      "Not the token owner"
    );

    NFTMarketItem memory newMarketItem = NFTMarketItem(
      tokenId,
      price,
      royalty,
      payable(msg.sender),
      INYWNFT(nftContractAddress).getCreator(tokenId),
      false
    );
    listedNFTs.push(newMarketItem);
    tokenIdToListId[tokenId] = _nftMarketListIds;
    isExist[tokenId] = true;
    _nftMarketListIds++;
    emit NYW__NFTListed(tokenId);
  }

  function delistNft(uint256 tokenId) external {
    require(isExist[tokenId] == true, "invalid tokenId");
    uint256 id = tokenIdToListId[tokenId];
    require(msg.sender == listedNFTs[id].seller, "Invalid seller!");
    deleteFromListArray(tokenId);

    emit NYW__NFTDelisted(tokenId);
  }

  function deleteFromListArray(uint256 tokenId) internal {
    uint256 id = tokenIdToListId[tokenId];
    uint256 lastTokenId = listedNFTs[_nftMarketListIds - 1].nftId;
    listedNFTs[id] = listedNFTs[_nftMarketListIds - 1];
    tokenIdToListId[id] = lastTokenId;
    listedNFTs.pop();
    delete tokenIdToListId[_nftMarketListIds - 1];
    delete isExist[tokenId];
    _nftMarketListIds--;
  }

  function buyNft(uint256 tokenId) public payable {
    require(isExist[tokenId] == true, "invalid tokenId");
    uint256 id = tokenIdToListId[tokenId];
    uint256 price = listedNFTs[id].price;
    uint256 royaltyPer = (price * listedNFTs[id].royalty) / deno;
    uint256 marketFee = (price * platformFee) / deno;

    require(msg.value >= price, "Insufficient funds");
    bool success;
    (success,) = payable(listedNFTs[id].creator).call{value: royaltyPer}("");
    require(success, "Failed sending royaltyFee");
    (success,) = payable(listedNFTs[id].seller).call{value: price - royaltyPer - marketFee}("");
    require(success, 'Failed sending funds to seller');

    if (msg.value > price) 
    {
      (success,) = payable(msg.sender).call{value: msg.value - price}("");
      require(success, 'Failed sending the rest funds');
    }
    listedNFTs[id].sold = true;
    nftContract.transferFrom(listedNFTs[id].seller, msg.sender, tokenId);
    deleteFromListArray(tokenId);
    emit NYW__NFTSold(tokenId, msg.sender, price);
  }

  receive() external payable {}

  function withdraw() external {
    require(msg.sender == owner, "Invalid owner");
    uint256 value = address(this).balance;
    (bool success,) = payable(msg.sender).call{value:value}("");
    require(success, 'Faild withdraw funds from market contract');
    emit NYW__withdraw(value);
  }
}
