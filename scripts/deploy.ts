import { ethers } from "hardhat";

async function main() {
    const presaleNftFactory = await ethers.getContractFactory('PresaleNft')
    const presaleNft = await presaleNftFactory.deploy("Nft-tutorialV1", "NTE")
    await presaleNft.deployed()

    console.log(`presaleNft deployed to ${presaleNft.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
