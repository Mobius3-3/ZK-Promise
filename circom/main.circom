/*
    Copyright 2018 0KIMS association.

    This file is part of circom (Zero Knowledge Circuit Compiler).

    circom is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    circom is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with circom. If not, see <https://www.gnu.org/licenses/>.
*/
pragma circom 2.0.0;

include "./poseidon.circom";

template Main() {
    signal input in[3]; // in[1] - AddressB
    signal output out[3];

    // todo: verify sha256

    component poseidon = Poseidon(1);

    poseidon.inputs[0] <== in[2];  // sha256(Promise signature, AddressB)
    out[0] <== poseidon.out;
    
    out[1] <== in[0]; // Promise signed by shared key
    out[2] <== in[2];
}

component main = Main();
