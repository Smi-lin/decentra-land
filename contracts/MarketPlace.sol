// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract VirtualToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("VirtualToken", "VTOK") Ownable(msg.sender) { // Pass msg.sender as the initial owner
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract Marketplace is Ownable {
    IERC721 public landContract;
    IERC721 public assetContract;
    IERC20 public paymentToken;

    struct Listing {
        uint256 id;
        address seller;
        uint256 price;
        bool isLand;
    }

    mapping(uint256 => Listing) public listings;
    uint256 private nextListingId;

    event LandListed(uint256 indexed id, uint256 indexed landId, address indexed seller, uint256 price);
    event AssetListed(uint256 indexed id, uint256 indexed assetId, address indexed seller, uint256 price);
    event Purchase(uint256 indexed id, address indexed buyer);

    constructor(IERC721 _landContract, IERC721 _assetContract, IERC20 _paymentToken) Ownable(msg.sender) { // Pass msg.sender as the initial owner
        landContract = _landContract;
        assetContract = _assetContract;
        paymentToken = _paymentToken;
    }

    function listLand(uint256 landId, uint256 price) public {
        require(landContract.ownerOf(landId) == msg.sender, "You are not the owner of this land");
        landContract.transferFrom(msg.sender, address(this), landId);

        listings[nextListingId] = Listing(nextListingId, msg.sender, price, true);
        emit LandListed(nextListingId, landId, msg.sender, price);

        nextListingId++;
    }

    function listAsset(uint256 assetId, uint256 price) public {
        require(assetContract.ownerOf(assetId) == msg.sender, "You are not the owner of this asset");
        assetContract.transferFrom(msg.sender, address(this), assetId);

        listings[nextListingId] = Listing(nextListingId, msg.sender, price, false);
        emit AssetListed(nextListingId, assetId, msg.sender, price);

        nextListingId++;
    }

    function buy(uint256 listingId) public {
        Listing storage listing = listings[listingId];
        require(listing.id == listingId, "Listing does not exist");
        require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), "Payment failed");

        if (listing.isLand) {
            landContract.transferFrom(address(this), msg.sender, listingId);
        } else {
            assetContract.transferFrom(address(this), msg.sender, listingId);
        }

        emit Purchase(listingId, msg.sender);
        delete listings[listingId];
    }
}
