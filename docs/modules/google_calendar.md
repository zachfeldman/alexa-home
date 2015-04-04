## Google Calendar plugin

Google Calendar leverages the natural language parsing ability of GCal's 'quick add' feature to add events to your Google Calendar.

The first time you add an event to your calendar your default web browser will open and ask you to grant permission for the Alexa Calendar to manage your calendar. If you grant access a file 'client_authorization.json' will be saved locally. This file contains both a Google supplied short term access token and a refresh token that can be used to automatically get a new access token.

General usage tips on quick add can be found here:

[https://support.google.com/calendar/answer/36604?hl=en](https://support.google.com/calendar/answer/36604?hl=en)

Note, however, that Alexa Calendar requires times to follow "at", e.g., "Breakfast at Tiffany's tomorrow at 8:45".  When there are multiple occurrences of  "at" in the event the app will look for the time after the final occurrence, e.g., "Meet Sally at the zoo at 9:00 tomorrow".

You can add all day events by not specifying a time.  

Google will understand expressions like "next Tuesday", "a week from Monday", "tomorrow", etc.

Recurring events are supported, e.g., "Meet Bob every Tuesday at Noon."

Limitations:

1. Durations of events are not supported. Each event will default length as set in your calendar settings.

2. Events are added to your primary calendar. You cannot specify which calendar to add an event to.

3. Events can only be added to your calendar, not deleted or modified.