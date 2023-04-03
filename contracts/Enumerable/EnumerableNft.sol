// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract EnumerableNft is ERC721Enumerable  {

    uint256 public constant MAX_ID = 20;

    constructor() ERC721("Enumerable token", "ENT") {

    }

    function mint(uint256 tokenId) external {
        require(tokenId > 0 && tokenId <= MAX_ID, "PresaleNft: token id should be from 1 to 20");
        _mint(msg.sender, tokenId);
    }
}