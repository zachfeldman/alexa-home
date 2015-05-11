Evernote Reminders

A. Setup

1. You'll need an Evernote account, of course.
2. You'll need a developers token. Get it at https://www.evernote.com/api/DeveloperToken.action

B. Use

1. Just say, "Alexa, remind me to [message body][time]," e.g., "Remind me have dinner with Andre tomorrow night at nine."

2. Setting a time for the reminder is optional.

If you do set a time, the entire message should come before the time  (e.g., "[Breakfast at Tiffany's with Katherine] [at eight thirty tomorrow]," NOT: "Breakfast with Katherine tomorrow at eight thirty at Tiffany's"). Beyond that, the syntax for setting times is very flexible:

in three days
three months from now
tomorrow night
may twenty third two thousand fifteen
april first twenty fifteen at ten in the morning
a week from next sunday at midnight
at two forty five
at four in the morning
six months from now at six o'clock

See the Chronic gem site for more examples. They won't all work, but most do.

C. Limitations

Cannot delete or edit reminders.




