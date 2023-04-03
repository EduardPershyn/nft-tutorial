const { assert, expect, use } = require('chai')
const { ethers } = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const { keccak256 } = ethers.utils

use(require('chai-as-promised'))

describe('Enumerable', function () {
    it('check countPrimes', async () => {
        const accounts = await hre.ethers.getSigners()

        const enumerableNftFactory = await ethers.getContractFactory('EnumerableNft')
        const enumerableNft = await enumerableNftFactory.deploy()
        await enumerableNft.deployed()

        const gameFactory = await ethers.getContractFactory('Game')
        const game = await gameFactory.deploy(enumerableNft.address)
        await game.deployed()

        for (let i = 1; i <= 20; i++) {
            await enumerableNft.connect(accounts[1]).mint(i);
        }
        let count = await game.connect(accounts[0]).countPrimes(accounts[1].getAddress());
        expect(count).to.be.equal(8);
    })
})