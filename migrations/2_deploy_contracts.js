var Monolith = artifacts.require('Monolith')

// weirdly enough: parameter order matters !name
module.exports = (deployer, network, accounts) => {
  const founders = [accounts[0], accounts[1]]
  deployer.deploy(Monolith, founders, 3)
}
