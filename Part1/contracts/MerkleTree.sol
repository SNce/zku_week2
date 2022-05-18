//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for(uint32 i = 0; i < 15; i++) {
            hashes.push(0);
        }

        // compute remaining 7 internal nodes.
        for(uint32 i = 0; i < 7; i++) {
            hashes[8 + i] = PoseidonT3.poseidon([hashes[2*i], hashes[2*i + 1]]);
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        
        uint32 modifiedIndex = 0;
        bool didInsert = false;

        // check if any of the 8 leaves is empty.
        for(uint32 i = 0; i < 8; ++i) {
            if(hashes[i] == 0) {
                hashes[i] = hashedLeaf;
                modifiedIndex = i;
                didInsert = true;
                break;
            }
        }


        if(didInsert) {
            // bubble up the hash computation. into all levels.
            uint32 internalIndexStart = 2 ** 3;
            for(uint32 i = 0; i < 3; ++i) {
                uint256 hash = 0;
                if(modifiedIndex % 2 == 0) {
                    hash = PoseidonT3.poseidon([hashes[modifiedIndex], hashes[modifiedIndex + 1]]);
                } else {
                    hash = PoseidonT3.poseidon([hashes[modifiedIndex - 1], hashes[modifiedIndex]]);
                }

                modifiedIndex = internalIndexStart + (modifiedIndex / 2);
                hashes[modifiedIndex] = hash;
            }
            
        }

        // return the root.
        return hashes[14];
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input);
    }
}
