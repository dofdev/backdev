# backdev

Design Principle(s)
  Simple Foundational Systems that handle the bulk of the problem
    but leave room for the company to be adaptive
  Lives Beyond You

~~setup a git~~
~~refactor to Monolith~~
~~setup truffle~~
~~test buyRelease function~~
look into fallback functions

newFeatures = [ networking ]
foreach (feature in newFeatures) {
  psuedo code(feature) // data and systems
  translate to solidity syntax
  test with truffle
}

refactor (now that I've gone through and packed all the features in)

share/test/refine/harden




the permDevs can keep the core small by using the credit climb


voluntary (moving on)
  credit decrement?
accidental (dead/lost accounts)
  no credit
malicious (hacked or otherwise)
  no credit

  how to undo damage? migration?
  report?
  freeze?


track time:
block.timestamp || now?


COMMANDS
truffle compile
truffle migrate
truffle test

!!!
migrations/2_deploy_contracts.js to change the contract constructor parameters

uint == uint256