var Monolith = artifacts.require('Monolith')

// weirdly enough: parameter order matters !name
module.exports = (deployer, network, accounts) => {
  const initCreditCap = 5
  const coFounders = [accounts[1]]
  deployer.deploy(Monolith, initCreditCap, coFounders, { from: accounts[0] })
}
