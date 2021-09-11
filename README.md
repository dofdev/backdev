# backdev

put off name schemes in the way of it inhibitting forward progress
*getting a clearer idea for how to express the idea is fine

~~setup a git~~
~~refactor to Monolith~~
~~setup truffle~~
~~test buyRelease function~~
look into fallback functions

keyFeatures = [compensation, networking, allocation agreement, ]
foreach (feature in keyFeatures) {
  psuedo code(feature) // data and systems
  translate to solidity syntax
  test with truffle
}

DEPRECATED?
(bool sent, bytes memory data) = address(this).call{value: msg.value}(abi.encodeWithSignature("deposit(uint256)", msg.value));
require(data.length > 0, "Data");
require(sent, "Failed to send Ether");


COMMANDS
truffle compile
truffle migrate
truffle test

!!!
migrations/2_deploy_contracts.js to change the contract constructor parameters