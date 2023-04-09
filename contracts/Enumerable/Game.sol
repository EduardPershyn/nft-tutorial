// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "hardhat/console.sol";

contract Game {

    ERC721Enumerable immutable public itemNft;

    constructor(ERC721Enumerable itemNft_) {
        itemNft = itemNft_;
    }

    function countPrimes(address owner) external view returns(uint256) {
        uint256 itemsCount = itemNft.balanceOf(owner);

        uint256 primeCount = 0;
        for (uint256 index = 0; index < itemsCount; ++index ) {
            uint256 tokenId = itemNft.tokenOfOwnerByIndex(owner, index);
            if (isPrime(tokenId)) {
                primeCount += 1;
            }
        }

        return primeCount;
    }

    function isPrime(uint256 n) internal pure returns(bool) {
        if (n <= 1)
            return false;
        for (uint256 i = 2; i * i <= n; i++) {
            if (n % i == 0) {
                return false;
            }
        }
        return true;
    }
}