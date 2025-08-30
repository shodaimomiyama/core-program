// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../src/TornadoCats.sol";
import "../src/Verifier.sol";
import "../src/MerkleTreeWithHistory.sol";

contract DeployScript is Script {
    function run() external {
        // 環境変数から秘密鍵を取得（.envファイルから）
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // ブロードキャスト開始
        vm.startBroadcast(deployerPrivateKey);

        // MiMCハッシャーのアドレス
        // 本番環境では実際のMiMCハッシャーコントラクトをデプロイするか、
        // 既存のアドレスを使用する必要があります
        address hasher = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // テスト用のダミーアドレス

        console.log("Deploying contracts...");
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        // 1. Verifierコントラクトのデプロイ
        Verifier verifier = new Verifier();
        console.log("Verifier deployed at:", address(verifier));

        // 2. TornadoCatsコントラクトのデプロイ
        uint256 denomination = 1 ether; // 1 ETH固定
        uint32 merkleTreeHeight = 20; // 2^20のリーフを持つMerkle Tree

        TornadoCats tornadoCats = new TornadoCats(
            IVerifier(address(verifier)),
            IHasher(hasher),
            denomination,
            merkleTreeHeight
        );
        console.log("TornadoCats deployed at:", address(tornadoCats));

        // デプロイ情報の表示
        console.log("========================================");
        console.log("Deployment Summary:");
        console.log("----------------------------------------");
        console.log("Network:", block.chainid);
        console.log("Verifier:", address(verifier));
        console.log("TornadoCats:", address(tornadoCats));
        console.log("Denomination:", denomination / 1e18, "ETH");
        console.log("Merkle Tree Height:", merkleTreeHeight);
        console.log("MiMC Hasher:", hasher);
        console.log("========================================");

        vm.stopBroadcast();
    }

    // Anvilローカルテスト用の簡易デプロイ関数
    function runLocal() external {
        // Anvilのデフォルトアカウント（秘密鍵）を使用
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        vm.startBroadcast(deployerPrivateKey);

        // テスト用のMiMCハッシャーアドレス
        address hasher = address(0x1337);

        // Verifierのデプロイ
        Verifier verifier = new Verifier();

        // TornadoCatsのデプロイ
        TornadoCats tornadoCats = new TornadoCats(
            IVerifier(address(verifier)),
            IHasher(hasher),
            0.1 ether, // テスト用に少額に設定
            20
        );

        console.log("Local deployment complete:");
        console.log("- Verifier:", address(verifier));
        console.log("- TornadoCats:", address(tornadoCats));

        vm.stopBroadcast();
    }
}
