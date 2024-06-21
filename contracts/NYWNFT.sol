// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract NYWNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public royalties;

    //-----------------------------------------------------------------------
    // EVENTS
    //-----------------------------------------------------------------------

    event NYW__TokenCreated(
        uint256 tokenId,
        address indexed creator,
        uint256 royalty,
        string uri
    );
    event NYW__TokenBurned(uint256 tokenId);

    //-----------------------------------------------------------------------
    // ERRORS
    //-----------------------------------------------------------------------

    error NYW__OnlyTokenOwner(uint256 tokenId);
    error NYW__NonexistantNFT(uint256 tokenId);

    constructor() ERC721("Generative AI NFT", "NYWN") Ownable(msg.sender) {}

    // ************************ //
    //      Main Functions      //
    // ************************ //

    function create(
        string memory uri,
        uint256 royalty
    ) external returns (uint256) {
        require(
            royalty >= 0 && royalty <= 30,
            "Royalty should be between 0 to 30"
        );

        uint256 tokenId = _tokenIds;

        tokenId += 1;
        console.log("tokenId: ", tokenId);

        creators[tokenId] = msg.sender;
        royalties[tokenId] = royalty;

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        _setApprovalForAll(msg.sender, address(this), true);

        _tokenIds = tokenId;

        emit NYW__TokenCreated(tokenId, msg.sender, royalty, uri);
        return tokenId;
    }

    function burn(uint256 tokenId) external {
        if (msg.sender != ownerOf(tokenId)) revert NYW__OnlyTokenOwner(tokenId);

        _burn(tokenId);
        delete creators[tokenId];
        delete royalties[tokenId];

        emit NYW__TokenBurned(tokenId);
    }

    function getCreator(uint256 tokenId) external view returns (address) {
        return creators[tokenId];
    }

    function getRoyalty(uint256 tokenId) external view returns (uint256) {
        return royalties[tokenId];
    }
}
