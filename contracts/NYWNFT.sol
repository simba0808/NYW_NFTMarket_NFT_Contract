// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NYWNFT is ERC721URIStorage {
  address payable owner;

  uint256 private _tokenIds;

  mapping(uint256 => string) private _tokenURIs;

  //-----------------------------------------------------------------------
  //EVENTS

  event NYW__TokenCreated(uint256 tokenId, address indexed creator, string uri);
  event NYW__TokenBurned(uint256 tokenId);
  
  //-----------------------------------------------------------------------
  //ERRORS

  error NYW__OnlyTokenOwner(uint256 tokenId);

  constructor() ERC721("Generative AI NFT", "NYW") {
    owner = payable(msg.sender);
  }

  // ************************ //
  //      Main Functions      //
  // ************************ //

  function create(string memory uri) external returns (uint256) {
    uint256 tokenId = _tokenIds;
    tokenId += 1;

    _safeMint(msg.sender, tokenId);
    _setTokenURI(tokenId, uri);

    _tokenIds = tokenId;

    emit NYW__TokenCreated(tokenId, msg.sender, uri);

    return tokenId;
  }

  function burn(uint256 tokenId) external {
    if (msg.sender != ownerOf(tokenId)) 
      revert NYW__OnlyTokenOwner(tokenId);
    _burn(tokenId);

    emit NYW__TokenBurned(tokenId);
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(ERC721URIStorage) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}