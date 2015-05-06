Alexa Google Now

This module allows you to send Google Now Cards (reminders, notes, and directions) to your Android phone using Alexa.

Setup:

1. Set your Google email and password in environment variables GOOGLE_EMAIL and GOOGLE_PASSWORD.

2. After Alexa Home starts, initialize the module by just saying "Google." This will sign you into your Google account.
If you have 2 step authentication, follow up the command with a pin code, either from authenticator app or a backup code, e.g., "Google one three three zero four six seven."

3. Send Google Now cards to phone.
	a. Directions:  "Google, directions to [location]," e.g., "Google, directions to Times Square New York." There is support for addresses, e.g.,  "Google directions to three zero one four six north Columbia," but Alexa needs to be able to recognize the street name. "Main Street" will work, "Tenino" probably won't.
	b. Note to Self:  "Goole, note [note]."
	c. Reminder: "Google, remind me to [reminder]," e.g., "Google, remind me to buy champagne and flowers tomorrow night/at 8pm/Wednesday, etc"

Limitations:

1. Doesn't work on Rasberry Pi setup. Seems to be an IceWeasel problem.
		