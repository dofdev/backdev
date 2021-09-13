// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7 <0.9.0;

contract Monolith {
  address[] private devs;
  mapping(address => uint) public credits;
  uint public creditCap;

  constructor(address[] memory founders, uint initCreditCap) {
    creditCap = initCreditCap;
    for (uint i = 0; i < founders.length; i++)
    {
      devs.push(founders[i]);
      credits[founders[i]] = creditCap;
    }
  }

  struct Expense {
    string reason;
    uint amount;
    uint[] signed;
  }
  mapping(address => Expense) public expenses;

  struct Project {
    string name;
    uint minPrice;
    uint devPayIndex;
    uint purchased;
    uint[] devs;
    string[] hashes;
  }
  Project[] private projects;
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
    expenses[msg.sender].signed = [devIndex(msg.sender)];
  }

  function signExpense(address dev) public {
    permission();
    expenses[dev].signed.push(devIndex(msg.sender));
  }

  function checkExpense() public {
    permission();
    
    for (uint i = 0; i < devs.length; i++)
    {
      if (credits[devs[i]] >= creditCap)
      {
        bool signed = false;
        for (uint k = 0; k < expenses[msg.sender].signed.length; k++)
        {
          if (expenses[msg.sender].signed[k] == i)
          {
            signed = true;
          }
        }

        require(signed, 'not signed by all perm devs');
      }
    }

    payable(msg.sender).transfer(expenses[msg.sender].amount);
  }

  function getContractBalance() public view returns (uint) { // test
    permission();
    return payable(address(this)).balance;
  }

  function newDev(address dev) public {
    permission();
    for (uint i = 0; i < devs.length; i++)
    {
      require(devs[i] != dev, "dev already exists");
    }
    devs.push(dev);
  }

  function devIndex(address dev) public view returns (uint) {
    permission();
    int index = -1;
    for (uint i = 0; i < devs.length; i++)
    {
      if (dev == devs[i])
      {
        index = int(i);
        break;
      }
    }
    require(index > -1, '');
    return uint(index);
  }
  
  function newProject(string memory name, uint minPrice, uint[] memory initDevs, string[] memory initHashes) public {
    permission();
    projects.push(Project(name, minPrice, 0, 0, initDevs, initHashes));
    
    for (uint i = 0; i < initDevs.length; i++)
    {
      credits[devs[initDevs[i]]]++;
      collection[devs[initDevs[i]]].push(projects.length - 1);
    }
  }

  function pushHash(uint projectIndex, string calldata hash) public {
    permission();
    projects[projectIndex].hashes.push(hash);
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
    return projects[projectIndex].hashes.length;
  }

  // user side
  function buyProject(uint projectIndex) public payable {
    Project storage p = projects[projectIndex];
    require(msg.value >= p.minPrice, "can't pay less than min price");

    address dev = devs[p.devs[p.devPayIndex]];
    uint totalDevCredits = 0;
    for (uint i = 0; i < p.devs.length; i++)
    {
      totalDevCredits += credits[devs[p.devs[i]]];
    }

    // contract takes half, rolling payouts
    // 1 - (1 - cut)^2 ? we can use builin exp == x**2
    uint precision = 100000;
    uint c = (credits[dev] * precision) / totalDevCredits;
    uint cut = (c * p.devs.length) / 2; 
    payable(dev).transfer((msg.value * cut) / 100000);

    p.devPayIndex++;
    if (p.devPayIndex >= p.devs.length)
    {
      p.devPayIndex = 0;
    }

    collection[msg.sender].push(projectIndex);
    p.purchased++;
  }

  function getHash(uint colIndex, uint hashIndex)
    public
    view
    returns (string memory)
  {
    return projects[collection[msg.sender][colIndex]].hashes[hashIndex];
  }

  function giftProject(uint colIndex, address to) public {
    uint[] storage col = collection[msg.sender];
    collection[to].push(col[colIndex]);
    col[colIndex] = col[col.length - 1];
    col.pop();
  }

  // how to handle someone going rogue? / lost or compromised account?
}
