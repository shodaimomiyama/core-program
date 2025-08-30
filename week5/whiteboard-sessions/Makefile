all: phase1 phase2 test

init: clean
	npm install
	pip3 install --break-system-packages -r requirements.txt

blank:
	git checkout -b blank
	rm contracts/src/TornadoCats.sol
	rm -rf circuits/multiplier*
	rm circuits/withdraw.circom

phase1:
	mkdir -p build

	# 2**16 (increased from 2**15 to accommodate larger circuit)
	snarkjs powersoftau new bn128 16 build/pot16_0000.ptau -v
	openssl rand -hex 10 | snarkjs powersoftau contribute build/pot16_0000.ptau build/pot16_0001.ptau --name="First contribution" -v

	snarkjs powersoftau prepare phase2 build/pot16_0001.ptau build/pot16_final.ptau -v

phase2:
	circom circuits/withdraw.circom --r1cs --wasm --sym -o build

	snarkjs groth16 setup build/withdraw.r1cs build/pot16_final.ptau build/withdraw_0000.zkey
	openssl rand -hex 10 | snarkjs zkey contribute build/withdraw_0000.zkey build/withdraw_0001.zkey --name="1st Contributor Name" -v
	snarkjs zkey export verificationkey build/withdraw_0001.zkey build/verification_key.json

	snarkjs zkey export solidityverifier build/withdraw_0001.zkey contracts/src/Verifier.sol
	forge fmt
	sed -i -e 's/pragma solidity \^0.6.11/pragma solidity 0.8.17/g' ./contracts/src/Verifier.sol
	sed -i -e 's/Groth16Verifier/Verifier/g' ./contracts/src/Verifier.sol

test:
	forge test -vvv

clean:
	rm -rf build/*
	rm -rf tmp/*
