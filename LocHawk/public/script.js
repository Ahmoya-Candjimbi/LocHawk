

function sendLocation(latitude, longitude) {

    fetch('/location', {

        method: 'POST',

        headers: { 'Content-Type': 'application/json' },

        body: JSON.stringify({ latitude, longitude })

    });

}



function getLocation() {

    if (navigator.geolocation) {

        navigator.geolocation.getCurrentPosition(position => {

            sendLocation(position.coords.latitude, position.coords.longitude);

        }, () => {

            console.log("Location access denied.");

        });

    } else {

        console.log("Geolocation not supported.");

    }

}



// Automatically request location on page load

window.onload = getLocation;









