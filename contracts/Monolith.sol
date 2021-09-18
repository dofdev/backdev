// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7 <0.9.0;

contract Monolith {
  address[] private devs;
  mapping(address => uint256) public credits;
  uint256 public creditCap;

  constructor(uint256 initCreditCap, address[] memory coFounders) {
    creditCap = initCreditCap;
    devs.push(msg.sender);
    credits[msg.sender] = creditCap;
    for (uint256 i = 0; i < coFounders.length; i++) {
      devs.push(coFounders[i]);
      credits[coFounders[i]] = creditCap;
    }
  }

  struct Expense {
    address payTo;
    string description;
    uint256 amount;
    mapping(address => uint256) consensus;
    bool sent;
  }
  uint256 private numExpenses;
  mapping(uint256 => Expense) private expenses;

  struct Project {
    string name;
    uint256 minPrice;
    uint256 devPayIndex;
    uint256 purchased;
    uint256[] devs;
    string[] hashes;
  }
  Project[] private projects;
  mapping(address => uint256[]) public collection;

  // dev side
    function getAdmins() internal view returns (uint256[] memory) {
    uint256 cnt = 0;
    for (uint256 i = 0; i < devs.length; i++) {
      if (credits[devs[i]] >= creditCap) {
        cnt++;
      }
    }
    uint256[] memory d = new uint256[](cnt);

    uint256 index = 0;
    for (uint256 i = 0; i < devs.length; i++) {
      if (credits[devs[i]] >= creditCap) {
        d[index++] = i;
      }
    }

    return d;
  }

  function permission() internal view {
    require(credits[msg.sender] >= creditCap, "sender != an admin");
  }

  function dropCredit() public {
    permission(); // then only a admin can do this
    // uint[] memory admins = getAdmins();
    require(getAdmins().length > 1, "NO! you are our only hope!");
    credits[msg.sender]--;
  }

  function removeCredit() public {
    permission();
  }

  function getCredits() public view returns (uint256) {
    return credits[msg.sender];
  }

  function newExpense(address payTo, string memory description, uint256 amount) public returns (uint256) {
    permission();
    Expense storage expense = expenses[numExpenses++];
    expense.payTo = payTo;
    expense.description = description;
    expense.amount = amount;
    expense.consensus[msg.sender] = amount;
    expense.sent = false;
    return numExpenses - 1;
  }

  function signExpense(uint256 index, uint256 amount) public returns (string memory) {
    permission();
    Expense storage expense = expenses[index];
    if (expense.sent) {
      return "expense has already been sent";
    }

    expense.consensus[msg.sender] = amount;

    uint256[] memory admins = getAdmins();
    for (uint256 i = 0; i < admins.length; i++) {
      if (expense.consensus[devs[admins[i]]] != amount) {
        return "consensus not reached yet";
      }
    }

    // check if contract has enough balance to pay
    if (address(this).balance < expense.amount * 2) { // playing it super safe, but might be a nice policy?
      return "not enough balance";
    }

    payable(expense.payTo).transfer(amount);
    expense.sent = true; // above or below the transfer?
    return "expense sent";
  }

  function getExpense(uint256 index) public view returns (string memory description, uint256 amount, bool sent) {
    permission();
    return (expenses[index].description, expenses[index].amount, expenses[index].sent);
  }

  function getContractBalance() public view returns (uint256) {
    // test
    permission();
    return payable(address(this)).balance;
  }

  mapping(address => address) private newDevConsensus;
  function newDev(address dev) public returns (string memory) {
    permission();
    newDevConsensus[msg.sender] = dev;

    for (uint256 i = devs.length - 1; i >= 0; i--) {
      if (devs[i] == dev) {
        return "dev already exists";
      }
      if (
        credits[devs[i]] >= creditCap && newDevConsensus[devs[i]] != dev
      ) {
        return "consensus not reached yet";
      }
    }

    devs.push(dev);
    return "new dev!";
  }

  function devIndex(address dev) public view returns (uint256) {
    permission();
    int256 index = -1;
    for (uint256 i = 0; i < devs.length; i++) {
      if (dev == devs[i]) {
        index = int256(i);
        break;
      }
    }
    require(index > -1, "");
    return uint256(index);
  }

  function newProject(
    string memory name,
    uint256 minPrice,
    uint256[] memory initDevs,
    string[] memory initHashes
  ) public {
    permission(); // convert to consensus check
    projects.push(Project(name, minPrice, 0, 0, initDevs, initHashes));

    for (uint256 i = 0; i < initDevs.length; i++) {
      if (credits[devs[initDevs[i]]] < creditCap) {
        credits[devs[initDevs[i]]]++;
      }
      collection[devs[initDevs[i]]].push(projects.length - 1);
    }
  }

  function pushHash(uint256 projectIndex, string memory hash) public {
    permission();
    projects[projectIndex].hashes.push(hash);
  }

  function minPriceChange(uint256 projectIndex, uint256 minPrice) public {
    permission();
    projects[projectIndex].minPrice = minPrice;
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

  function getHashesLength(uint256 projectIndex)
    public
    view
    returns (uint256)
  {
    return projects[projectIndex].hashes.length;
  }

  // user side
  function buyProject(uint256 projectIndex) public payable {
    Project storage p = projects[projectIndex];
    require(msg.value >= p.minPrice, "can't pay less than min price");

    address dev = devs[p.devs[p.devPayIndex]];
    uint256 totalDevCredits = 0;
    for (uint256 i = 0; i < p.devs.length; i++) {
      totalDevCredits += credits[devs[p.devs[i]]];
    }

    // contract takes half, rolling payouts
    // 1 - (1 - cut)^2 ? we can use builin exp == x**2
    uint256 precision = 100000;
    uint256 c = (credits[dev] * precision) / totalDevCredits;
    uint256 cut = (c * p.devs.length) / 2;
    payable(dev).transfer((msg.value * cut) / 100000);

    p.devPayIndex++;
    if (p.devPayIndex >= p.devs.length) {
      p.devPayIndex = 0;
    }

    collection[msg.sender].push(projectIndex);
    p.purchased++;
  }

  function getHash(uint256 colIndex, uint256 hashIndex)
    public
    view
    returns (string memory)
  {
    return projects[collection[msg.sender][colIndex]].hashes[hashIndex];
  }

  function giftProject(uint256 colIndex, address to) public {
    uint256[] storage col = collection[msg.sender];
    collection[to].push(col[colIndex]);
    col[colIndex] = col[col.length - 1];
    col.pop();
  }
}
