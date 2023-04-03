const { assert, expect, use } = require('chai')
const { ethers } = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const { keccak256 } = ethers.utils

use(require('chai-as-promised'))

describe('WhitelistSale', function () {
    function hashNode(account, tokenId) {
        //console.log(account, tokenId);
        return ethers.utils.solidityKeccak256(["address", "uint256"], [account, tokenId]);
    };

    it('allow only whitelisted accounts to mint', async () => {
        const accounts = await hre.ethers.getSigners()

        let whitelisted = new Map<string, number>();
        for (let i = 0; i < 5; i++) {
            whitelisted.set(accounts[i].address, i);
        }
        let notWhitelisted = new Map<string, number>();
        for (let i = 5; i < 10; i++) {
            notWhitelisted.set(accounts[i].address, i);
        }
        console.log(whitelisted);
        console.log(notWhitelisted);

        const leaves = new Array(...whitelisted).map(entry => hashNode(entry[0], entry[1]));
        const tree = new MerkleTree(leaves, keccak256, { sort: true })
        const merkleRoot = tree.getHexRoot()

        const presaleNftFactory = await ethers.getContractFactory('PresaleNft')
        const presaleNft = await presaleNftFactory.deploy("Test", "TST")
        await presaleNft.deployed()

        const merkleProof1 = tree.getHexProof(hashNode(accounts[1].address, 1));
        const merkleProof2 = tree.getHexProof(hashNode(accounts[2].address, 2));
        const invalidMerkleProof = tree.getHexProof(hashNode(accounts[8].address, 8));

        {
            let root = merkleRoot;
            let tx = await presaleNft.connect(accounts[0]).setMerkleRoot(root);
            let receipt = await tx.wait();
            assert.equal(receipt.status, true, "root should be set")
        }

        await expect(presaleNft.connect(accounts[1]).presale(merkleProof1, 1)).to.not.be.rejected
        await expect(presaleNft.connect(accounts[1]).presale(merkleProof1, 1)).to.be.rejectedWith("PresaleNft: white list ticket already used!");

        await expect(presaleNft.connect(accounts[2]).presale(merkleProof2, 2)).to.not.be.rejected
        await expect(presaleNft.connect(accounts[2]).presale(merkleProof1, 1)).to.be.rejectedWith("PresaleNft: invalid merkle proof");

        await expect(presaleNft.connect(accounts[8]).presale(invalidMerkleProof, 8)).to.be.rejectedWith("PresaleNft: invalid merkle proof");
    })
})