const Monolith = artifacts.require('Monolith')

contract('Monolith test', async (accounts) => {
  it('new release and subsequent purchase', async () => {
    const monolith = await Monolith.deployed()

    // const credits = (await monolith.getCredits()).toNumber()
    // console.log('credits: ' + credits)

    // const b = (await monolith.getProjectsLength()).toNumber()

    const devs = [accounts[0], accounts[1]]
    await monolith.newProject('test', 1500 * 1e12, devs, { from: accounts[0] })

    // const a = (await monolith.getProjectsLength()).toNumber()
    // assert(a > b, 'projects did not increment')

    // const collectionLength = (
    //   await monolith.getCollectionLength({ from: accounts[1] })
    // ).toNumber()
    // assert(collectionLength > 0, 'collection')

    // Purchase
    await monolith.buyProject(0, { from: accounts[2], value: 1500000 * 1e12 })
    // const before = (await monolith.getPurchased(0)).toNumber()
    // const after = (await monolith.getPurchased(0)).toNumber()
    // assert(after > before, "purchased did not increment")
    // console.log("before:" + before + " after:" + after)

    await monolith.buyProject(0, { from: accounts[3], value: 1500000 * 1e12 })


    
    // const held = BigInt(await monolith.balanceHeld())
    // const contract = BigInt(await monolith.getContractBalance())
    // assert(contract > held, 'business balance is not less than contract balance')
    // console.log("this got logged")
  })
})

// assert(await web3.eth.getBalance == 0, "its empty D:")
