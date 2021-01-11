# minimal-NEC-treasury

The minimal implementation of a contract to hold NEC treasury funds.

The necDAO is a DAOstack based organisation existing on the Ethereum blockchain. It is represented by the following address: https://etherscan.io/address/0xe56b4d8d42b1c9ea7dda8a6950e3699755943de7.

NEC holders have an additional 16.5k ETH pledged to them which are not held directly by the DAO due to security concerns of the complex code base, especially given the value of these assets. Instead these funds are currently held in the 3/5 multisig shown at this address: https://etherscan.io/address/0xc6cde7c39eb2f0f0095f41570af89efc2c1ea828

The NectarTreasury.sol contract is a proposed solution to this, which will allow the 17k ETH to be transferred into the control of the DAO.

Once the ETH is transferred into the treasury contract, this simple implementation allows the following:
- Any NEC holder can claim their proportional share of the ETH, permanently burning their tokens in the process.
- The DAO is able to withdraw the funds to itself, or transfer ownership of the treasury to another address (in the case of the DAO upgrading). Since the DAO must vote in order to execute any function on an external contract, this will ensure that there is always a delay period before funds can be withdrawn for any reason.

This design means that theoretically even in the worst case if the DAO were compromised (which is considered very unlikely) that at least NEC holders could claim their proportional share of the treasury before funds were withdrawn.
