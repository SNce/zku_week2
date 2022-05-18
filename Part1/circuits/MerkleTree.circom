pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    var nLeafHashes = 2**n / 2;
    var nInternalHashes = nLeafHashes - 1;
    var nHashes = nLeafHashes + nInternalHashes;

    component poseidon[nHashes];

    // initialize hash components;
    for(var i = 0; i < nHashes; i++) {
        poseidon = Poseidon(2);
    }

    // compute leaf hashes
    for(var i = 0; i < nLeafHashes; i++) {
        poseidon[i].inputs[0] <== leaves[2*i];
        poseidon[i].inputs[1] <== leaves[2*i + 1];
    }

    // compute internal hashes.
    for(var i = 0; i < nInternalHashes; i++) {
        poseidon[nLeafHashes + i].inputs[0] <== poseidon[2*i].out;
        poseidon[nLeafHashes + i].inputs[1] <== poseidon[2*i + 1].out;
    }

    root <== poseidon[nHashes - 1];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    signal resForLevel[n+1];
    resForLevel[0] <== leaf;

    component poseidon[n];
    component mux[n];

    for(var i = 0; i < n; i++) {

        mux[i] = MultiMux1(2);

        // Assuming path_index value of '0' means
        // the current path_element is to the left
        // of the current resultForLevel.
        mux[i].c[0][0] <== path_elements[i];
        mux[i].c[0][1] <== resForLevel[i];

        mux[i].c[1][0] <== resForLevel[i];
        mux[i].c[1][1] <== path_elements[i];

        mux[i].s <== path_index[i];

        poseidon[i] = Poseidon(2);
        poseidon[i].inputs[0] <== mux[i].out[0];
        poseidon[i].inputs[1] <== mux[i].out[1];

        resForLevel[i+1] <== poseidon[i].out;
    }

    root <== resForLevel[n];
}