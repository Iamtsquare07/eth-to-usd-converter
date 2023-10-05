# ETH To USD Converter

This tool allows users to convert Ether into USD and offers them the opportunity to receive a complimentary token upon its usage.

Preview on: https://codepen.io/iamtsquare07/full/yLGRQxE

To use the app:

- Deploy token.sol
- Use the token contract address to deploy app.sol
- Add the token.sol contract address to the app.js
- Add the token.sol ABI to the etherusdAbi.json
- Change the supplierAddress in the app.js to the address you used when deploying the contract
- Uncomment the sendTokenToUser function in the index.js
- Perform any transaction and you will get some tokens sent to your Metamask.

##  To view the tokens, follow these steps:

- Use the contract address you've created.
- Import the token into your Metamask wallet.
- Make sure to select the network you used when deploying the contract.
