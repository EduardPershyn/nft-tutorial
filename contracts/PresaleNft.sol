// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract PresaleNft is ERC721, Ownable  {

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant PRICE = 0.0001 ether;
    bytes32 public merkleRoot;

    address private _nextOwner;
    //mapping(uint256 => bool) private whiteListMinted;
    BitMaps.BitMap private wlBitMap;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {

    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function presale(bytes32[] calldata merkleProof, uint256 tokenId) external {
        require(
            MerkleProof.verify(
                merkleProof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender, tokenId))),
            "PresaleNft: invalid merkle proof");

        _updateWhiteList(tokenId);
        _mintWithSupply(tokenId);
    }

    function _updateWhiteList(uint256 tokenId) internal {
//        require(whiteListMinted[tokenId] == false, "PresaleNft: white list place already used!");
//        whiteListMinted[tokenId] = true;

        require(BitMaps.get(wlBitMap, tokenId) == false, "PresaleNft: white list ticket already used!");
        BitMaps.set(wlBitMap, tokenId);
    }

    function mint(uint256 tokenId) external payable {
        require(msg.value == PRICE, "PresaleNft: msg ethers value is not correct");
        _mintWithSupply(tokenId);
    }

    function _mintWithSupply(uint256 tokenId) internal {
        require(tokenId < MAX_SUPPLY, "PresaleNft: token id exceeds max supply");
        _mint(msg.sender, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qm/";
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _nextOwner = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == _nextOwner, "PresaleNft: the sender is not next owner");

        _transferOwnership(_nextOwner);
        _nextOwner = address(0);
    }
}