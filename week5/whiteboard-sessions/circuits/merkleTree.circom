pragma circom 2.1.2;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

// MiMC([left, right]) を計算する
template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = MiMCSponge(2, 220, 1);
    hasher.ins[0] <== left;
    hasher.ins[1] <== right;
    hasher.k <== 0;
    hash <== hasher.outs[0];
}

// s == 0 なら [in[0], in[1]] を返す
// s == 1 なら [in[1], in[0]] を返す
template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    // s must be binary (0 or 1)
    s * (1 - s) === 0;
    
    // If s == 0: out[0] = in[0], out[1] = in[1]
    // If s == 1: out[0] = in[1], out[1] = in[0]
    // Use intermediate signals to satisfy quadratic constraints
    signal aux0_0;
    signal aux0_1;
    signal aux1_0;
    signal aux1_1;
    
    aux0_0 <== (1 - s) * in[0];
    aux0_1 <== s * in[1];
    out[0] <== aux0_0 + aux0_1;
    
    aux1_0 <== (1 - s) * in[1];
    aux1_1 <== s * in[0];
    out[1] <== aux1_0 + aux1_1;
}

// Merkleルートとリーフに対してMerkleプルーフが正しいかどうかを検証する
// pathIndicesはpathElementがMerkleパスの左側か右側かを示す0/1の配列である
template MerkleTreeChecker(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    component selectors[levels];
    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        hashers[i] = HashLeftRight();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];
    }

    root === hashers[levels - 1].hash;
}
