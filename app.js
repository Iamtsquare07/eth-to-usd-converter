let provider;
let account;

async function connectMetamask() {
    try {
      // Check if Metamask is available
      if (typeof window.ethereum !== 'undefined') {
        // Request account access from the user
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      // Create the Web3 provider using MetaMask's injected Ethereum provider
        provider = new Web3(window.ethereum);
  
        account = accounts[0];
        // console.log(account);
        console.log('Metamask connected:', window.ethereum.selectedAddress);
        alert(`You're connected to Metamask with address: ${window.ethereum.selectedAddress}
        This project is intended for educational purposes. If you wish to engage with the app, you'll need to deploy the contract yourself and update the necessary inputs accordingly.
        `)
      
    } else {
        console.log('Metamask not available.');
        alert('Metamask wallet not installed or not available, please install Metamask.')
      }
    } catch (error) {
      console.error('Error connecting Metamask:', error);
    }
  }
// Check if the browser has an Ethereum provider
if (window.ethereum) {
    try {
      // Request access to the user's Ethereum accounts
      await window.ethereum.request({ method: 'eth_requestAccounts' });
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      // Create the Web3 provider using MetaMask's injected Ethereum provider
      provider = new Web3(window.ethereum);
  
      account = accounts[0];
    } catch (error) {
      // Handle error if user denies account access or MetaMask is not available
      console.error('Error connecting to MetaMask:', error);
    }
  } else {
    // Handle case where MetaMask is not installed or not supported
    console.error('MetaMask is not installed or not supported in this browser.');
  }

  document.getElementById('wallet').addEventListener('click', connectMetamask)


  export async function sendTokensToUser(amountToSend) {
    try {
      // Check if MetaMask is connected
      if (typeof window.ethereum !== 'undefined') {
  
        const contractAddress = ''; // Deploy the contract to get address
        async function fetchJsonFile(filePath) {
            try {
              const response = await fetch(filePath);
              if (!response.ok) {
                throw new Error(`Failed to fetch JSON file: ${response.status} ${response.statusText}`);
              }
              const json = await response.json();
              return json;
            } catch (error) {
              console.error('Error fetching JSON file:', error);
            }
          }
        
        var contractABI = await fetchJsonFile('./etherusdABI.json');
        const contract = new provider.eth.Contract(contractABI, contractAddress);
  
         // To test the app, ensure your address contains Etherusd Tokens. You can begin by deploying the contract with your address to obtain the tokens.
        const supplierAddress = "";
        const userBalance = await contract.methods.balanceOf(supplierAddress).call();
  
        if (web3.utils.toBN(userBalance).lt(web3.utils.toBN(amountToSend))) {
          console.error("Not enough tokens to send.");
          return;
        }
  
        const tx = await contract.methods.transfer(account, amountToSend).send({ from: supplierAddress });
  
        console.log(`Sent ${amountToSend} tokens to ${account}`);
      } else {
        console.log('MetaMask not available.');
      }
    } catch (error) {
      console.error('Error sending tokens:', error);
    }
  }