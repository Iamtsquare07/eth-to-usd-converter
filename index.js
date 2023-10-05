
async function queryApi() {
    try {
        // Fetch the current price of Ether (ETH) in dollars from CoinGecko
        const response = await axios.get('https://api.coingecko.com/api/v3/simple/price', {
          params: {
            ids: 'ethereum',
            vs_currencies: 'usd',
          },
        });

        return response;
      } catch (error) {
        console.error('Error fetching exchange rate:', error);
        return null;
      }
}

async function convertEthToDollars(value) {
    try {
        const response = await queryApi();
        const ethToUsdRate = response.data.ethereum.usd;
    
        // Convert Ether (ETH) to dollars
        const dollarsValue = value * ethToUsdRate;
    
    
        return dollarsValue;
    } catch (error) {
        console.error('Error converting ETH to dollars:', error);
        return null;
    }
}

async function convertDollarsToEth(value) {
    try {
        const response = await queryApi();
        const ethToUsdRate = response.data.ethereum.usd;
    
        // Convert Dollars to Ether
        const ethValue = value / ethToUsdRate;
    
        return ethValue;
    } catch (error) {
        console.error('Error converting ETH to dollars:', error);
        return null;
    }
}


function removeCurrencyAndNonNumeric(inputString) {
    // Regex pattern to match currency symbols and any character that is not a number (0-9)
    const pattern = /[^0-9.]/g; // Allow decimal points

    const cleanedString = inputString.replace(pattern, '');

    return cleanedString;
}

let eth = document.getElementById('eth-input');
let dollars = document.getElementById('usd-input');

function convertEthToUsd() {
    let ethValue = parseInt(removeCurrencyAndNonNumeric(eth.value));
    if(!ethValue) {
        eth.focus()
        return;
    }
    convertEthToDollars(ethValue)
    .then(dollar => {
        dollars.value = `$ ${dollar.toFixed(2)}`
    })
}
eth.addEventListener('input', convertEthToUsd)

function convertUsdToEth() {
    let dollarsValue = parseInt(removeCurrencyAndNonNumeric(dollars.value))
    if(!dollarsValue) {
        dollars.focus()
        return;
    }
    convertDollarsToEth(dollarsValue)
    .then(ether => {
        eth.value = ether.toFixed(4);
    })
}
dollars.addEventListener('input', convertUsdToEth)

window.addEventListener('DOMContentLoaded', convertEthToUsd)
document.getElementById('convert-button').addEventListener('click', () => {
    if(eth.value) {
        convertEthToUsd()
    }else if(dollars.value) {
        convertUsdToEth()
    }else {
        alert('Enter Ether or Dollars to convert')
    }

})