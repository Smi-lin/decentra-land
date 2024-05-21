// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract LandOwnership is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Land {
        uint256 id;
        string name;
        uint256 x;
        uint256 y;
        uint256 size;
    }

    mapping(uint256 => Land) public lands;

    constructor() ERC721("VirtualLand", "VLAND") Ownable(msg.sender) {} // Pass msg.sender as the initial owner

    function createLand(
        string memory name,
        uint256 x,
        uint256 y,
        uint256 size,
        string memory tokenURI
    ) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newLandId = _tokenIds.current();

        lands[newLandId] = Land(newLandId, name, x, y, size);
        _mint(msg.sender, newLandId);
        _setTokenURI(newLandId, tokenURI);

        return newLandId;
    }

    function transferLand(uint256 landId, address to) public {
        require(ownerOf(landId) == msg.sender, "You are not the owner of this land");
        _transfer(msg.sender, to, landId);
    }
}
