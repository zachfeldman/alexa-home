# Uber

The Uber plugin will request a cab to you and attempt to pre-format your destination (though this isn't working super well right now). It uses the following environment variables:

````bash
# True or false - whether you want to sandbox requests or actually request a real ride
UBER_REAL_RIDE

# Uber credentials
UBER_SERVER_TOKEN
UBER_BEARER_TOKEN

# Your default location, i.e. "123 Main Street, Anytown, USA 21212"
UBER_DEFAULT_LOCATION
````

To request a ride, use this command:

`alexa get me a cab to Union Square stop`