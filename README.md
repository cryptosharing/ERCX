# ERCX
This standard adds a new right of Non-Fungible Token that the right to use. Through this standard, you can achieve :

- Separation of the right to use and ownership of Non-Fungible Token
- Non-secured lease Non-Fungible Token
- You can continue to use it after you mortgage the Non-Fungible Token
- Metaverse sharing economy

It is precisely because of the separation of ownership and use right that the utilization rate of assets can be greater. You must distinguish between the rights of the user and the owner.

The EIP consists of two interfaces, found as {IERCX},{IERCXEnumerable}. The first one and the {https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol } are required in the contract to be ERCX compliant. The enumerable extension is provided separately in {ERCXEnumerable}.

## install
install the required dependencies:

```bash
npm install
```

## Compile
compile the contract:

```bash
npx hardhat compile
```

## Test
test the case

```bash
npx hardhat test
```
