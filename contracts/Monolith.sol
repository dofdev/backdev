// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// Design Principle(s)
  // Simple Foundational Systems that handle the bulk of the problem
    // but leave room for the company to be adaptive
  // Lives Beyond Yourself

contract Monolith {
  mapping(address => uint) public shares;
  uint public shareMax;

  constructor(address[] memory founders, uint initShareMax) {
    shareMax = initShareMax;
    for (uint i = 0; i < founders.length; i++)
    {
      shares[founders[i]] = shareMax;
    }
  }

  struct Release {
    string name;
    uint256 price;
    uint256 purchased;
  }
  Release[] public catalog;
  mapping(uint256 => string[]) private hashes;
  mapping(uint256 => address[]) private devs;
  mapping(address => uint256[]) public collection;

  // dev side
  function permission() internal view {
    require(shares[msg.sender] >= shareMax, "sender != a shareMax dev");
  }
  
  function newRelease(string memory name, uint256 price, address[] memory initDevs) public {
    permission();
    catalog.push(Release(name, price, 0));
    
    devs[catalog.length - 1] = initDevs;
    for (uint i = 0; i < initDevs.length; i++)
    {
      shares[initDevs[i]]++;
      collection[initDevs[i]].push(catalog.length - 1);
    }
  }

  function pushHash(uint256 catIndex, string calldata hash) public {
    permission();
    hashes[catIndex].push(hash);
  }

  function priceChange(uint256 catIndex, uint256 price) public {
    permission();
    catalog[catIndex].price = price;
  }

  function getCatalogLength() public view returns (uint256) {
    return catalog.length;
  }

  function getCollectionLength() public view returns (uint256) {
    return collection[msg.sender].length;
  }

  function getHashesLength(uint256 catIndex) public view returns (uint256) {
    return hashes[catIndex].length;
  }

  // user side
  function buyRelease(uint256 catIndex) public payable {
    Release storage r = catalog[catIndex];
    require(msg.value >= r.price, "can't pay less than min price");

    (bool sent, bytes memory data) = address(this).call{value: msg.value}(abi.encodeWithSignature("register(string)", "MyName"));
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

  // COMPENSATION
  // share system => onboarding system
  
  // ? can't just shove ether into a smart contact address ?

  // cache share data when we initialize the new Release
  // shares = clamp(number of past projects contributed to, 0, 3)
  // can the max be modified? *only increased **during a release


  // the business half gets transferred straight away

  // then trigger the contributor compensation at certain amount gained:
  // !!the trigger is checked for in the buyRelease function
  // once the stored transactions >= number of contributors * multiplier(stored in release)



  // no direct access to the business wallet (allocation agreement)
  // no access to the contract wallet (auto compensation)

  // how to handle someone going rogue?
}
