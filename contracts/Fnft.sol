// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FractionalNFT is IERC721Receiver {
    IERC20 public paymentToken;

    constructor(address _paymentToken) {
        paymentToken = IERC20(_paymentToken);
    }

    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 shares;
        uint256 soldShares;
    }
    mapping(address => mapping(uint256 => uint256)) public sharesOwned;
    mapping(uint256 => Listing) public listings;
    uint256 public listingId = 1;
    uint256 public platformFee = 10; // 0.1%
    uint256 public tokenBalance = paymentToken.balanceOf(address(this));

    event ListingCreated(
        address indexed seller,
        uint256 tokenId,
        uint256 price,
        uint256 shares
    );

    event SharesPurchased(
        uint256 indexed listingId,
        address buyer,
        uint256 shares
    );

    event SharesSold(uint256 indexed listingId, address seller, uint256 shares);

    event SharesTransferred(
        uint256 indexed listingId,
        address from,
        address to,
        uint256 shares
    );

    function listNFT(
        address _nft,
        uint256 _tokenId,
        uint256 _price,
        uint256 _shares
    ) external {
        require(_shares > 0, "Invalid number of shares");
        require(_price > 0, "Invalid price");

        IERC721 nft = IERC721(_nft);
        require(
            nft.ownerOf(_tokenId) == msg.sender,
            "Not the owner of the NFT"
        );

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        listings[listingId] = Listing({
            seller: msg.sender,
            tokenId: _tokenId,
            price: _price,
            shares: _shares,
            soldShares: 0
        });

        listingId++;
        emit ListingCreated(msg.sender, _tokenId, _price, _shares);
    }

    function buyShares(uint256 _listingId, uint256 _shares) external payable {
        Listing storage listing = listings[_listingId];
        require(
            listing.soldShares + _shares <= listing.shares,
            "Not enough shares available"
        );
        require(_shares > 0, "Invalid number of shares");
        // require(tokenBalance > 0, "Token balance is empty");

        uint256 totalPrice = listing.price * _shares;
        uint256 platformFeeAmount = (totalPrice * platformFee) / 100;
        uint256 totalPricePlusFee = totalPrice + platformFeeAmount;

        require(msg.value >= totalPrice, "Insufficient Ether value sent");
        require(
            msg.value >= totalPricePlusFee,
            "Insufficient price + platform fee"
        );
        // tokenBalance -= totalPrice;
        paymentToken.transfer(listing.seller, totalPrice);

        listing.soldShares += _shares;
        sharesOwned[msg.sender][_listingId] += _shares;
        emit SharesPurchased(_listingId, msg.sender, _shares);
    }

    function sellShares(uint256 _listingId, uint256 _shares) external {
        Listing storage listing = listings[_listingId];
        require(_shares > 0, "Invalid number of shares");
        require(
            _shares <= sharesOwned[msg.sender][_listingId],
            "Not enough shares owned"
        );

        uint256 totalPrice = listing.price * _shares;
        paymentToken.transferFrom(msg.sender, address(this), totalPrice);
        // tokenBalance += totalPrice;

        (bool success, ) = msg.sender.call{value: totalPrice}("");
        require(success, "Failed to send Ether");

        listing.soldShares -= _shares;
        sharesOwned[msg.sender][_listingId] -= _shares;
        emit SharesSold(_listingId, msg.sender, _shares);
    }

    function transferShares(
        uint256 _listingId,
        address _to,
        uint256 _shares
    ) external {
        require(
            sharesOwned[msg.sender][_listingId] >= _shares,
            "Not enough shares owned"
        );

        sharesOwned[msg.sender][_listingId] -= _shares;
        sharesOwned[_to][_listingId] += _shares;
        emit SharesTransferred(_listingId, msg.sender, _to, _shares);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
