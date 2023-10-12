// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Psalmuel is ERC721URIStorage, Ownable {
    constructor(address initialAddress) ERC721("Psalmuel", "SAM") Ownable(initialAddress) {}

    function mint(
        address _to,
        uint _tokenId,
        string calldata _URI
    ) external onlyOwner {
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _URI);
    }
}