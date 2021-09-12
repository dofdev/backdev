const Monolith = artifacts.require('Monolith')

contract('Monolith test', async (accounts) => {
  it('new release and subsequent purchase', async () => {
    const monolith = await Monolith.deployed()

    // const credits = (await monolith.getCredits()).toNumber()
    // console.log('credits: ' + credits)

    // const b = (await monolith.getProjectsLength()).toNumber()

    const devs = [accounts[0], accounts[1], accounts[2]]
    await monolith.newProject('test', 1500 * 1e12, devs, { from: accounts[0] })

    // const a = (await monolith.getProjectsLength()).toNumber()
    // assert(a > b, 'projects did not increment')
    
    // await monolith.newProject('solo', 1500 * 1e12, [accounts[2]], { from: accounts[0] })
    // await monolith.buyProject(1, { from: accounts[3], value: 15000000 * 1e12 })


    // const collectionLength = (
    //   await monolith.getCollectionLength({ from: accounts[1] })
    // ).toNumber()
    // assert(collectionLength > 0, 'collection')

    // Purchase
    await monolith.buyProject(0, { from: accounts[5], value: 15000000 * 1e12 })
    // await monolith.buyProject(0, { from: accounts[6], value: 15000000 * 1e12 })
    // await monolith.buyProject(0, { from: accounts[7], value: 15000000 * 1e12 })


    await monolith.submitExpense("because i want money", BigInt(5000000 * 1e12), { from: accounts[1] })
    await monolith.signExpense(accounts[1], { from: accounts[0] })
    await monolith.checkExpense({ from: accounts[1] })
    // console.log(sent);
    
    // balance = await monolith.getBalance.call(accounts[])
    // 42.98 - 27.97 = -15.01
    // 15.94 - 23.44 = +7.5

    // 70.00 - 54.99 = -15.01
    // 26.90 - 25.17 = +1.73

    // 1.73 / 7.5 = 0.230667
    // 1.73 / 15.01 = 0.115256 * 2 = 0.230512


    // 114.73 - 104.35 = 10.38
    // 25.17 - 23.44 = 1.73

    // 104.35 - 93.97 = 10.38
    // 15.94 - 14.21 = 1.73 

    // 1.73 / (10.38 + 10.38 + 1.73) = 0.076923

    // 1 / 11 = 0.09 * 3 = 0.27 / 2 = 0.135

    // const before = (await monolith.getPurchased(0)).toNumber()
    // const after = (await monolith.getPurchased(0)).toNumber()
    // assert(after > before, "purchased did not increment")
    // console.log("before:" + before + " after:" + after)



    
    // const held = BigInt(await monolith.balanceHeld())
    // const contract = BigInt(await monolith.getContractBalance())
    // assert(contract > held, 'business balance is not less than contract balance')
    // console.log("this got logged")
  })
})

// assert(await web3.eth.getBalance == 0, "its empty D:")
