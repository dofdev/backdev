// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7 <0.9.0;

// Design Principle(s)
  // Simple Foundational Systems that handle the bulk of the problem
    // but leave room for the company to be adaptive
  // Lives Beyond Yourself

contract Monolith {
  mapping(address => uint) public credits;
  uint public creditCap;

  constructor(address[] memory founders, uint initCreditCap) payable {
    creditCap = initCreditCap;
    for (uint i = 0; i < founders.length; i++)
    {
      credits[founders[i]] = creditCap;
    }
  }

  uint256 public balanceHeld; // public or permission?

  struct Project {
    string name;
    uint256 price;
    uint256 devPayIndex;
    uint256 purchased;
  }
  Project[] public projects;
  mapping(uint256 => string[]) private hashes;
  mapping(uint256 => address[]) private devs;
  mapping(address => uint256[]) public collection;

  // dev side
  function permission() internal view {
    require(credits[msg.sender] >= creditCap, "sender != a creditCap dev");
  }

  function getContractBalance() public view returns (uint256) { // test
    return payable(address(this)).balance;
  }

  function getCredits() public view returns (uint) {
    return credits[msg.sender];
  }
  
  function newProject(string memory name, uint256 price, address[] memory initDevs) public {
    permission();
    projects.push(Project(name, price, 0, 0));
    
    devs[projects.length - 1] = initDevs;
    for (uint i = 0; i < initDevs.length; i++)
    {
      credits[initDevs[i]]++;
      collection[initDevs[i]].push(projects.length - 1);
    }
  }

  function pushHash(uint256 projectIndex, string calldata hash) public {
    permission();
    hashes[projectIndex].push(hash);
  }

  function priceChange(uint256 projectIndex, uint256 price) public {
    permission();
    projects[projectIndex].price = price;
  }

  function getProjectsLength() public view returns (uint256) {
    return projects.length;
  }

  function getPurchased(uint256 projectIndex) public view returns (uint256) {
    return projects[projectIndex].purchased;
  }

  function getCollectionLength() public view returns (uint256) {
    return collection[msg.sender].length;
  }

  function getHashesLength(uint256 projectIndex) public view returns (uint256) {
    return hashes[projectIndex].length;
  }

  // user side
  function buyProject(uint256 projectIndex) public payable {
    Project storage r = projects[projectIndex];
    require(msg.value >= r.price, "can't pay less than min price");

    
    address dev = devs[projectIndex][r.devPayIndex]; // payable?
    uint totalDevCredits = 0;
    for (uint i = 0; i < devs[projectIndex].length; i++)
    {
      totalDevCredits += credits[devs[projectIndex][i]];
    }

    uint256 c = credits[dev];
    uint256 t = totalDevCredits;
    uint256 l = devs[projectIndex].length;
    // 1 - (1 - cut)^2 ? we can use builin exp == x**2
    uint256 cut = (msg.value * ((((c * 1000) / t) * l) / 2)) / 1000;
    payable(dev).transfer(cut);

    r.devPayIndex++;
    if (r.devPayIndex >= devs[projectIndex].length)
    {
      r.devPayIndex = 0;
    }


    collection[msg.sender].push(projectIndex);
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

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "uint overflow from multiplication");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "division by zero");
    uint256 c = a / b;
    return c;
  }

  // how to handle someone going rogue? / lost or compromised account?
}
