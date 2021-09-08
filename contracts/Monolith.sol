// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Monolith {
  address private dev;

  constructor() {
    dev = msg.sender;
  }

  struct Release {
    string name;
    uint256 price;
    uint256 purchased;
  }
  Release[] public catalog;
  mapping(uint256 => string[]) private hashes;
  mapping(address => uint256[]) public collection;

  // dev side
  function newRelease(string calldata name, uint256 price) public {
    require(msg.sender == dev, "sender != dev");
    catalog.push(Release(name, price, 0));
    // dev gets free copy
    collection[msg.sender].push(catalog.length - 1);
  }

  function pushHash(uint256 catIndex, string calldata hash) public {
    require(msg.sender == dev);
    hashes[catIndex].push(hash);
  }

  function priceChange(uint256 index, uint256 price) public {
    require(msg.sender == dev);
    catalog[index].price = price;
  }

  function getCatalogLength() public view returns (uint256) {
    return catalog.length;
  }

  function getHashesLength(uint256 catIndex) public view returns (uint256) {
    return hashes[catIndex].length;
  }

  // user side
  function buyRelease(uint256 catIndex) public payable {
    Release storage r = catalog[catIndex];
    require(msg.value >= r.price, "can't pay less than min price");

    (bool sent, bytes memory data) = dev.call{value: msg.value}(abi.encodeWithSignature("register(string)", "MyName"));
    // require(data.length > 0, "Data");
    require(sent, "Failed to send Ether");

    collection[msg.sender].push(catIndex);
    r.purchased++;
  }

  function getHash(uint256 colIndex, uint256 hashIndex)
    public
    view
    returns (string memory)
  {
    string[] memory h = hashes[collection[msg.sender][colIndex]];
    return h[hashIndex];
  }
}
