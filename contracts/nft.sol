// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Psalmuel is ERC721URIStorage, Ownable {
    constructor(
        address initialAddress
    ) ERC721("Psalmuel", "SAM") Ownable(initialAddress) {}

    function mint(address _to, uint _tokenId) external onlyOwner {
        _mint(_to, _tokenId);
    }
}

// contract SamNFT is ERC721("Psalmuel", "SAM") {

//     function mint(address recipient, uint256 tokenId) public payable {
//         _mint(recipient, tokenId);
//     }

//     function tokenURI(
//         uint256 id
//     ) public view virtual override returns (string memory) {
//         return "base-marketplace";
//     }
// }
