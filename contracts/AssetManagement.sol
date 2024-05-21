// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Manually include the Counters library code
library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement underflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract AssetManagement is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _assetIds;

    constructor() ERC721("VirtualAsset", "VAST") Ownable(msg.sender) {} // Pass msg.sender as the initial owner

    function createAsset(string memory tokenURI) public onlyOwner returns (uint256) {
        _assetIds.increment();
        uint256 newAssetId = _assetIds.current();

        _mint(msg.sender, newAssetId);
        _setTokenURI(newAssetId, tokenURI);

        return newAssetId;
    }

    function transferAsset(uint256 assetId, address to) public {
        require(ownerOf(assetId) == msg.sender, "You are not the owner of this asset");
        _transfer(msg.sender, to, assetId);
    }
}
