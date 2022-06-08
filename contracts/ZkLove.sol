//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "./verifier.sol";
import "hardhat/console.sol";

contract ZkPromise {
    Verifier verifier = new Verifier();

    struct Promise {
        bytes32 promiseSig; // sha256(promise, AddressB)
        address owner;
        uint256 startTime;
        uint256 sealTime;
        bool unsealed;
    }

    mapping(address => PromiseLetter) public owner2promise;
    mapping(address => address) public unlocker2owner;

    mapping(uint => bool) internal usedProof;

    constructor() {}

    function createPromise(
        uint[8] memory proof,
        uint promiseSig,
        uint unlockerHash,
        uint allHash
    ) public {
        Promise storage promise = owner2promise[_msgSender()];

        if (promise.owner != address(0)) {
            require(_msgSender() == promise.owner, "Err");
        }
        
        require(verifyProof(proof, promiseSig, unlockerHash, allHash), "Err");
        usedProof[proof[0]] = true;

        if (promise.owner == address(0)) {
            //new user
            promise.owner = _msgSender();
        }
        promise.promiseSig = promiseSig;
        promise.promiseSig = promiseSig; // sha256(promise, AddressA)
        promise.promiseSig = promiseSig; // sha256(promise, AddressB)
        promise.startTime = block.timestamp;
        promise.unlockTime = 0;
        promise.unlocked = false;
    }

    function unlockChecker(
        uint[8] memory proof,
        uint promiseSig,
        uint unlockerHash,
        uint allHash
    ) public view returns(bool){
        return verifyProof(proof, promiseSig, unlockerHash, allHash);
    }

    function unlockBox(
        uint[8] memory proof,
        uint promiseSig,
        uint unlockerHash,
        uint allHash
    ) public {
        require(verifyProof(proof, promiseSig, unlockerHash, allHash), "Err");
        require(keccak256(abi.encodePacked(unlockerHash, _msgSender())) == allHash, "ZkSafebox::setBoxhash: pswHash error");
    }

    function verifyProof(
        uint[8] memory proof,
        uint promiseSig,
        uint unlockerHash,
        uint allHash
    ) internal view returns (bool) {
        return verifier.verifyProof(
            [proof[0], proof[1]],
            [[proof[2], proof[3]], [proof[4], proof[5]]],
            [proof[6], proof[7]],
            [promiseSig, unlockerHash, allHash]
        );
    }
}
