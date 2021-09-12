var Monolith = artifacts.require('Monolith')

// weirdly enough: parameter order matters !name
module.exports = (deployer, network, accounts) => {
  const founders = [accounts[0], accounts[1]]
  const initCreditCap = 5
  deployer.deploy(Monolith, founders, initCreditCap, { from: accounts[0] })
}
