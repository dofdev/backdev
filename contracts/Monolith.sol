// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7 <0.9.0;

contract Monolith {
  mapping(address => uint) public credits;
  uint public creditCap;

  constructor(address[] memory founders, uint initCreditCap) {
    creditCap = initCreditCap;
    for (uint i = 0; i < founders.length; i++)
    {
      credits[founders[i]] = creditCap;
    }
  }

  struct Expense {
    string reason;
    uint amount;
    address[] signed;
  }
  mapping(address => Expense) public expenses;

  struct Project {
    string name;
    uint minPrice;
    uint devPayIndex;
    uint purchased;
  }
  Project[] public projects;
  mapping(uint => address[]) private devs;
  mapping(uint => string[]) private hashes;
  mapping(address => uint[]) public collection;

  // dev side
  function permission() internal view {
    require(credits[msg.sender] >= creditCap, "sender != a creditCap dev");
  }

  function dropCredit() public {
    permission(); // then only a permDev can do this
    credits[msg.sender]--;
  }

  function removeCredit() public {
    permission();
  }

  function getCredits() public view returns (uint) {
    return credits[msg.sender];
  }

  function submitExpense(string memory reason, uint amount) public {
    permission();
    expenses[msg.sender].reason = reason;
    expenses[msg.sender].amount = amount;
    expenses[msg.sender].signed = [msg.sender];
  }

  function signExpense(address dev) public {
    permission();
    expenses[dev].signed.push(msg.sender);
  }

  function checkExpense() public payable returns (bool) {
    permission();
    
    // new project requires consensus?
    // that way it can be used to get the activePermDevs...

    // right now we can we loop over all the projects devs
    for (uint i = 0; i < projects.length; i++)
    {
      for (uint j = 0; j < devs[i].length; j++)
      {
        if (credits[devs[i][j]] >= creditCap)
        {
          bool signed = false;
          for (uint k = 0; k < expenses[msg.sender].signed.length; k++)
          {
            if (expenses[msg.sender].signed[k] == devs[i][j])
            {
              signed = true;
              // break;
            }
          }

          if (!signed)
          {
            return false;
          }
        }
      }
    }

    payable(msg.sender).transfer(expenses[msg.sender].amount);
    return true;
  }

  function getContractBalance() public view returns (uint) { // test
    permission();
    return payable(address(this)).balance;
  }
  
  function newProject(string memory name, uint minPrice, address[] memory initDevs) public {
    permission();
    projects.push(Project(name, minPrice, 0, 0));
    
    devs[projects.length - 1] = initDevs;
    for (uint i = 0; i < initDevs.length; i++)
    {
      credits[initDevs[i]]++;
      collection[initDevs[i]].push(projects.length - 1);
    }
  }

  function pushHash(uint projectIndex, string calldata hash) public {
    permission();
    hashes[projectIndex].push(hash);
  }

  function minPriceChange(uint projectIndex, uint minPrice) public {
    permission();
    projects[projectIndex].minPrice = minPrice;
  }

  function getProjectsLength() public view returns (uint) {
    return projects.length;
  }

  function getPurchased(uint projectIndex) public view returns (uint) {
    return projects[projectIndex].purchased;
  }

  function getCollectionLength() public view returns (uint) {
    return collection[msg.sender].length;
  }

  function getHashesLength(uint projectIndex) public view returns (uint) {
    return hashes[projectIndex].length;
  }

  // user side
  function buyProject(uint projectIndex) public payable {
    Project storage r = projects[projectIndex];
    require(msg.value >= r.minPrice, "can't pay less than min price");

    address dev = devs[projectIndex][r.devPayIndex];
    uint totalDevCredits = 0;
    for (uint i = 0; i < devs[projectIndex].length; i++)
    {
      totalDevCredits += credits[devs[projectIndex][i]];
    }

    // contract takes half, rolling payouts
    // 1 - (1 - cut)^2 ? we can use builin exp == x**2
    uint precision = 100000;
    uint c = (credits[dev] * precision) / totalDevCredits;
    uint cut = (c * devs[projectIndex].length) / 2; 
    payable(dev).transfer((msg.value * cut) / 100000);

    r.devPayIndex++;
    if (r.devPayIndex >= devs[projectIndex].length)
    {
      r.devPayIndex = 0;
    }

    collection[msg.sender].push(projectIndex);
    r.purchased++;
  }

  function getHash(uint colIndex, uint hashIndex)
    public
    view
    returns (string memory)
  {
    string[] memory h = hashes[collection[msg.sender][colIndex]];
    return h[hashIndex];
  }

  // how to handle someone going rogue? / lost or compromised account?
}
