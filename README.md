# SURFY

SURFY is multi-chain crypto payment application.

## Features
* Multichain wallet including EVM, Solana, XRPL, Tron, Cosmos(TBD), etc
* Payment with QR code, NFC(TBD)

## Architecture
### Application Architecture
![image](https://github.com/user-attachments/assets/18436a49-a542-487b-b00e-d278c4e9fb9b)

1. The ui folder represents the views displayed on the screen. 
The viewmodel contains the data to be rendered by the view, and the view subscribes to it. 

2. The domain folder represents any actions that occur within the app as objects, such as fetching token prices or retrieving wallet balances. 

3. The repository folder serves as the first entry point for calling or storing each piece of data, communicating with either the server or the local cache depending on the conditions. 

4. The service folder is the layer that interacts with the server. The cache folder represents the local cache.


### Payment System Architecture
![image](https://github.com/user-attachments/assets/7a1d99df-e603-43f2-8a51-a3c4dcdfb7b5)

To enable users to pay with their desired tokens and merchants to receive settlements in their preferred tokens (especially stablecoins), we plan to actively utilize DEX aggregators (such as 1inch swap) on each chain. We will automatically swap tokens in LP pools existing on each chain and deploy gateway contracts on each chain to send the converted stablecoins to the merchants.

## Website
* https://docs.surfy.network
* https://x.com/surfyxyz
* https://warpcast.com/~/channel/surfy
