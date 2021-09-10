const Monolith = artifacts.require('Monolith')

contract('Monolith test', async (accounts) => {
  it('new release and subsequent purchase', async () => {
    const monolith = await Monolith.deployed()
    const b = (await monolith.getCatalogLength()).toNumber()

    const devs = [accounts[0], accounts[1]]
    await monolith.newRelease('test', 1500 * 1e12, devs, { from: accounts[0] })

    const a = (await monolith.getCatalogLength()).toNumber()
    assert(a > b, 'catalog did not increment')

    const collectionLength = (
      await monolith.getCollectionLength({ from: accounts[1] })
    ).toNumber()
    assert(collectionLength > 0, 'collection')

    
    // await monolith.buyRelease(0, { from: accounts[2], value: 1500 * 1e12 })
    // console.log("this got logged")
  })
})

// assert(await web3.eth.getBalance == 0, "its empty D:")
