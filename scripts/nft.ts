import { ethers } from "hardhat";

async function main() {
  const psalmuel = await ethers.deployContract("Psalmuel", []);

  await psalmuel.waitForDeployment();

  console.log(`Psalmuel deployed to ${psalmuel.target}`);

  // const psalmuel = await ethers.getContractAt("Psalmuel", "")

  const [signer] = await ethers.getSigners();
  const _to = signer;
  const _tokenId = 1;
  const _URI = "ipfs://QmZWpxyk22XomdCHM656TyqN91K5fRBZdfcphs7nC8SmrP";
  await psalmuel.mint(_to, _tokenId, _URI);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
