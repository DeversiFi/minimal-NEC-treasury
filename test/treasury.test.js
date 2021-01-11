const SimpleNEC = artifacts.require('./SimpleNEC.sol')
const NectarTreasury = artifacts.require('./NectarTreasury.sol')

const BN = web3.utils.BN
const _1e18 = new BN('1000000000000000000')

contract('NectarTreasury', (accounts) => {

  let nec, treasury

  beforeEach('redeploy contract', async function () {
    nec = await SimpleNEC.new('Nectar', 'NEC')
    treasury = await NectarTreasury.new(nec.address)
  })

  it('deploy: treasury gets deployed and ETH transfered to it', async () => {
    const address = await treasury.necToken()
    assert.equal(address, nec.address, 'Nectar token address not set')
    await treasury.send(_1e18.mul(new BN(10)), { from: accounts[0] })
    const treasurySize = await treasury.treasurySize()
    assert.equal(treasurySize.toString(), _1e18.mul(new BN(10)).toString(), 'Treasury not expected size')
  })

  it('claim: ETH share can be claimed and NEC is burned', async () => {
    await treasury.send(_1e18.mul(new BN(10)), { from: accounts[0] })
    await nec.mint(accounts[1], _1e18.mul(new BN(50)))
    await nec.approve(treasury.address, _1e18.mul(new BN(25)), { from: accounts[1] })
    await treasury.burnTokensAndClaimeShareOfTreasury(_1e18.mul(new BN(25)), { from: accounts[1] })
    const treasurySize = await treasury.treasurySize()
    assert.equal(treasurySize.toString(), _1e18.mul(new BN(5)).toString(), 'Treasury not expected size')
    const necBalance = await nec.balanceOf(accounts[1])
    assert.equal(necBalance.toString(), _1e18.mul(new BN(25)).toString())
  })

  it('withdraw: owner/DAO can withdraw the funds', async () => {
    await treasury.send(_1e18.mul(new BN(10)), { from: accounts[0] })
    await treasury.transferOwnership(accounts[9])

    await treasury.transferTreasuryFundsToDAO(_1e18.mul(new BN(3)), { from: accounts[9] })

    const treasurySize = await treasury.treasurySize()
    assert.equal(treasurySize.toString(), _1e18.mul(new BN(7)).toString(), 'Treasury not expected size')
  })


})
