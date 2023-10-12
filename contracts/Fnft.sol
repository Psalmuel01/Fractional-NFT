// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTFractionalization {
    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 shares;
        uint256 soldShares;
        mapping(address => uint256) sharesOwned;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public listingId = 1;
    uint256 public platformFee = 10; // 0.1%

    IERC20 public paymentToken;

    constructor(address _paymentToken) {
        paymentToken = IERC20(_paymentToken);
    }

    function listNFT(address _nftContract, uint256 _tokenId, uint256 _price, uint256 _shares) external {
        require(_shares > 0, "Invalid number of shares");
        require(_price > 0, "Invalid price");

        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "Not the owner of the NFT");

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        listings[listingId] = Listing({
            seller: msg.sender,
            tokenId: _tokenId,
            price: _price,
            shares: _shares,
            soldShares: 0
        });

        listingId++;
    }

    function buyShares(uint256 _listingId, uint256 _shares) external {
        Listing storage listing = listings[_listingId];
        require(listing.soldShares + _shares <= listing.shares, "Not enough shares available");
        require(_shares > 0, "Invalid number of shares");

        uint256 totalPrice = listing.price * _shares;
        paymentToken.transferFrom(msg.sender, address(this), totalPrice);

        uint256 platformFeeAmount = totalPrice * platformFee / 10000;
        paymentToken.transfer(address(this), platformFeeAmount); 

        uint256 sellerAmount = totalPrice - platformFeeAmount;
        paymentToken.transfer(listing.seller, sellerAmount);

        listing.soldShares += _shares;
        listing.sharesOwned[msg.sender] += _shares;
    }

    function transferShares(uint256 _listingId, address _to, uint256 _shares) external {
        Listing storage listing = listings[_listingId];
        require(listing.sharesOwned[msg.sender] >= _shares, "Not enough shares owned");

        listing.sharesOwned[msg.sender] -= _shares;
        listing.sharesOwned[_to] += _shares;
    }
}