async function queryApi() {
  try {
    // Fetch the current price of Ether (ETH) in dollars from CoinGecko
    const response = await axios.get(
      "https://api.coingecko.com/api/v3/simple/price",
      {
        params: {
          ids: "ethereum",
          vs_currencies: "usd",
        },
      }
    );

    return response;
  } catch (error) {
    console.error("Error fetching exchange rate:", error);
    return null;
  }
}

async function convertEthToDollars(value) {
  try {
    const response = await queryApi();
    const ethToUsdRate = response.data.ethereum.usd;

    const dollarsValue = value * ethToUsdRate;

    return dollarsValue;
  } catch (error) {
    console.error("Error converting ETH to dollars:", error);
    return null;
  }
}

async function convertDollarsToEth(value) {
  try {
    const response = await queryApi();
    const ethToUsdRate = response.data.ethereum.usd;

    const ethValue = value / ethToUsdRate;

    return ethValue;
  } catch (error) {
    console.error("Error converting ETH to dollars:", error);
    return null;
  }
}

function removeCurrencyAndNonNumeric(inputString) {
  // Use a regular expression to match numbers (including negative) and decimal points
  const pattern = /[-+]?([0-9]*\.[0-9]+|[0-9]+)/g;

  const cleanedArray = inputString.match(pattern);

  // Join the matched numbers and decimal points back into a single string
  const cleanedString = cleanedArray ? cleanedArray.join("") : "";

  return cleanedString;
}

let eth = document.getElementById("eth-input");
let dollars = document.getElementById("usd-input");

function convertEthToUsd() {
  let ethValue = removeCurrencyAndNonNumeric(eth.value);
  if (!ethValue) {
    eth.focus();
    return;
  }
  convertEthToDollars(ethValue).then((dollar) => {
    dollars.value = dollar.toFixed(2);
  });
}
eth.addEventListener("input", convertEthToUsd);

function convertUsdToEth() {
  let dollarsValue = removeCurrencyAndNonNumeric(dollars.value);
  if (!dollarsValue) {
    dollars.focus();
    return;
  }
  convertDollarsToEth(dollarsValue).then((ether) => {
    eth.value = ether.toFixed(4);
  });
}
dollars.addEventListener("input", convertUsdToEth);

function isMobileDevice() {
  return window.innerWidth < 768;
}

const arrows = document.getElementById("arrows");
let isClicked = false;
if (isMobileDevice()) {
  arrows.innerHTML = `<i class="fa-solid fa-arrows-up-down"></i>`;
  const mobileDropdowns = document.querySelectorAll(".mobile-dropdown");
  mobileDropdowns.forEach(function (dropdown) {
    const trigger = dropdown.querySelector("a");
    const menu = dropdown.querySelector(".mobile-dropdown-menu");

    trigger.addEventListener("click", function (event) {
      event.preventDefault(); 

      if (isClicked) {
        menu.style.display = "none"; 
      } else {
        menu.style.display = "block"; 
      }

      isClicked = !isClicked; 
    });
  });
} else {
  arrows.innerHTML = `<i class="fa-solid fa-arrow-right-arrow-left"></i>`;
}

window.addEventListener("DOMContentLoaded", convertEthToUsd);
document.getElementById("convert-button").addEventListener("click", () => {
  if (eth.value) {
    convertEthToUsd();
  } else if (dollars.value) {
    convertUsdToEth();
  } else {
    alert("Enter Ether or Dollars to convert");
  }
});
