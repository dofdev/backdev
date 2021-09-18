# backdev  

## design principles  
- simple foundational systems that leave room for the company to be adaptive
- lives beyond the developer(s) use case

## todo  
~~setup a git~~  
~~refactor to Monolith~~  
~~setup truffle~~  
~~test buyRelease function~~  
~~refactor (now that I've gone through and packed all the features in)~~
~~test real gas prices / where to deploy this contract?~~
~~cap credits on new project~~
~~drop credit if single perm dev is a soft-lock~~
~~deploy and connect our contract to the unity nethereum front end using ganache~~
~~consensus systems... made progress but don't have the right functionality for returning a consensus status~~
propogate the new consensus system
front-end!
share/refine/harden
look into fallback functions  

better consensus functionality?  
the limiting factor for consensus is for every creditCap dev to be active
so we need some system for removing the inactive ones
add dev to project (require consensus)?  
new project requires consensus?  
how to undo damage? migration?


## cmds  
truffle compile  
truffle migrate  
truffle test  

## faq  
truffle test -> update the nethereum contract address
constructor parameters are in migrations/2_deploy_contracts.js 
uint == uint256  