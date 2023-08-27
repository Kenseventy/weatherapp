document.addEventListener('DOMContentLoaded', function() {
    const inputBox = document.querySelector('input[type="text"]');
    const searchButton = document.querySelector('button');
    const displayArea = document.querySelector('.display-area');  // Moved this outside for reusability

    // Function to check for temperature alert
    async function checkTemperature() {
        let response = await fetch('https://weathertrackerfunction.azurewebsites.net/api/httptrigger1?code=eqV_0M-xsvnXUdFHxuHLVIb6OC1KYuYJBONQI0uljZLPAzFucBoqDA==');
        let data = await response.text();
    
        if (data.includes('Alert')) {
            // Show alert on your webpage
            const alertBox = document.createElement('div');  // Create a new element for the alert
            alertBox.innerText = data;
            alertBox.style.color = 'red';  // Color it red for emphasis, you can style as you see fit
            displayArea.appendChild(alertBox);
        }
    }

    // Function to handle the search action
    function handleSearch() {
        const cityName = inputBox.value;

        fetch('/search', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `city=${cityName}`,
        })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                alert(data.error);
            } else {
                // Display the weather data
                displayArea.innerHTML = `
                    City: ${data.city}<br>
                    Temperature: ${data.temperature}°C<br>
                    Description: ${data.description}
                `;
            }
        })
        .catch(error => {
            alert('Error fetching weather data.');
        });
    }

    // Listen for button click
    searchButton.addEventListener('click', handleSearch);

    // Listen for "Enter" key press in the input box
    inputBox.addEventListener('keydown', function(event) {
        if (event.keyCode === 13) {  // 13 is the key code for the "Enter" key
            event.preventDefault();  // Prevent the default action (form submission, if any)
            handleSearch();  // Trigger the search action
        }
    });

    // Call the checkTemperature function on page load
    checkTemperature();
});
