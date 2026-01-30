Title: Create events

URL Source: https://developers.google.com/workspace/calendar/api/guides/create-events

Markdown Content:
[Skip to main content](https://developers.google.com/workspace/calendar/api/guides/create-events#main-content)

*   [Home](https://developers.google.com/workspace)
*   [Google Calendar](https://developers.google.com/workspace/calendar)
    *   [Overview](https://developers.google.com/workspace/calendar)
    *   [Guides](https://developers.google.com/workspace/calendar/api/guides/overview)
    *   [Reference](https://developers.google.com/workspace/calendar/api/v3/reference)
    *   [Support](https://developers.google.com/workspace/calendar/api/support)

*   [All products](https://developers.google.com/workspace/products-menu)
*   [Resources](https://developers.google.com/workspace/resources-menu)

*   Get started

*   [Calendar API overview](https://developers.google.com/workspace/calendar/api/guides/overview)
*   [Get started with Google Workspace](https://developers.google.com/workspace/guides/get-started)
*   [Configure OAuth consent](https://developers.google.com/workspace/guides/configure-oauth-consent)
*   [Choose scopes](https://developers.google.com/workspace/calendar/api/auth)
*   Calendar API

*   
Use the Calendar API

    *   [Create events](https://developers.google.com/workspace/calendar/api/guides/create-events)
    *   [Recurring events](https://developers.google.com/workspace/calendar/api/guides/recurringevents)
    *   [Event types](https://developers.google.com/workspace/calendar/api/guides/event-types)
    *   [Manage focus time, out of office, and working location events](https://developers.google.com/workspace/calendar/api/guides/calendar-status)
    *   [Synchronize resources](https://developers.google.com/workspace/calendar/api/guides/sync)
    *   [Get push notifications](https://developers.google.com/workspace/calendar/api/guides/push)
    *   [Get versioned resources](https://developers.google.com/workspace/calendar/api/guides/version-resources)
    *   [Extended properties](https://developers.google.com/workspace/calendar/api/guides/extended-properties)
    *   [Pagination](https://developers.google.com/workspace/calendar/api/guides/pagination)
    *   [Batch requests](https://developers.google.com/workspace/calendar/api/guides/batch)
    *   [Improve performance](https://developers.google.com/workspace/calendar/api/guides/performance)
    *   [Manage quotas](https://developers.google.com/workspace/calendar/api/guides/quota)
    *   [Handle API errors](https://developers.google.com/workspace/calendar/api/guides/errors)

*   Cal DAV API

*   [Overview](https://developers.google.com/workspace/calendar/caldav/v2/guide)
*   Extend & automate

*   [Add-ons](https://developers.google.com/workspace/add-ons/calendar)
*   [Apps Script](https://developers.google.com/apps-script/reference/calendar)

Create events Stay organized with collections  Save and categorize content based on your preferences.
-----------------------------------------------------------------------------------------------------

*   On this page
*   [Add an event](https://developers.google.com/workspace/calendar/api/guides/create-events#add_an_event)
    *   [Add event metadata](https://developers.google.com/workspace/calendar/api/guides/create-events#metadata)
    *   [Add Drive attachments to events](https://developers.google.com/workspace/calendar/api/guides/create-events#attachments)
    *   [Add video and phone conferences to events](https://developers.google.com/workspace/calendar/api/guides/create-events#conferencing)

Imagine an app that helps users find the best hiking routes. By adding the hiking plan as a calendar event, the users get a lot of help in staying organized automatically. Google Calendar helps them to share the plan and reminds them about it so they can get prepared with no stress. Also, thanks to seamless integration of Google products, Google Now pings them about the time to leave and Google Maps direct them to the meeting spot on time.

This article explains how to create calendar events and add them to your users' calendars.

Add an event
------------

To create an event, call the [`events.insert()`](https://developers.google.com/workspace/calendar/v3/reference/events/insert) method providing at least these parameters:

*   `calendarId` is the calendar identifier and can either be the email address of the calendar on which to create the event or a special keyword `'primary'` which will use the primary calendar of the logged in user. If you don't know the email address of the calendar you would like to use, you can check it either in the calendar's settings of the Google Calendar web UI (in the section "Calendar Address") or you can look for it in the result of the [`calendarList.list()`](https://developers.google.com/workspace/calendar/v3/reference/calendarList/list) call.
*   `event` is the event to create with all the necessary details such as start and end. The only two required fields are the `start` and `end` times. See the [`event` reference](https://developers.google.com/workspace/calendar/v3/reference/events) for the full set of event fields. 

In order to successfully create events, you need to:

*   Set your OAuth scope to `https://www.googleapis.com/auth/calendar` so that you have edit access to the user's calendar.
*   Ensure the authenticated user has write access to the calendar with the `calendarId` you provided (for example by calling [`calendarList.get()`](https://developers.google.com/workspace/calendar/v3/reference/calendarList/get) for the `calendarId` and checking the `accessRole`).

### Add event metadata

You can optionally add event metadata when you create a calendar event. If you choose not to add metadata during creation, you can update many fields using the [`events.update()`](https://developers.google.com/workspace/calendar/v3/reference/events/update); however, some fields, such as the event ID, can only be set during an [`events.insert()`](https://developers.google.com/workspace/calendar/v3/reference/events/insert) operation.

Location Adding an address into the location field enables features such as "time to leave" or displaying a map with the directions.Event ID When creating an event, you can choose to generate your own event ID that conforms to our format requirements. This enables you to keep entities in your local database in sync with events in Google Calendar. It also prevents duplicate event creation if the operation fails at some point after it is successfully executed in the Calendar backend. If no event ID is provided, the server generates one for you. See the [event ID reference](https://developers.google.com/workspace/calendar/v3/reference/events#id) for more information.Attendees The event you create appears on all the primary Google Calendars of the attendees you included with the same event ID. If you set `sendUpdates` to `"all"` or `"externalOnly"` in your insert request, the corresponding attendees receive an email notification for your event. To learn more, see [events with multiple attendees](https://developers.google.com/workspace/calendar/concepts#events_with_attendees).
The following examples demonstrate creating an event and setting its metadata:

```
// Refer to the Go quickstart on how to setup the environment:
// https://developers.google.com/workspace/calendar/quickstart/go
// Change the scope to calendar.CalendarScope and delete any stored credentials.

event := &calendar.Event{
  Summary: "Google I/O 2015",
  Location: "800 Howard St., San Francisco, CA 94103",
  Description: "A chance to hear more about Google's developer products.",
  Start: &calendar.EventDateTime{
    DateTime: "2015-05-28T09:00:00-07:00",
    TimeZone: "America/Los_Angeles",
  },
  End: &calendar.EventDateTime{
    DateTime: "2015-05-28T17:00:00-07:00",
    TimeZone: "America/Los_Angeles",
  },
  Recurrence: []string{"RRULE:FREQ=DAILY;COUNT=2"},
  Attendees: []*calendar.EventAttendee{
    &calendar.EventAttendee{Email:"lpage@example.com"},
    &calendar.EventAttendee{Email:"sbrin@example.com"},
  },
}

calendarId := "primary"
event, err = srv.Events.Insert(calendarId, event).Do()
if err != nil {
  log.Fatalf("Unable to create event. %v\n", err)
}
fmt.Printf("Event created: %s\n", event.HtmlLink)
```

```
// Refer to the Java quickstart on how to setup the environment:
// https://developers.google.com/workspace/calendar/quickstart/java
// Change the scope to CalendarScopes.CALENDAR and delete any stored
// credentials.

Event event = new Event()
    .setSummary("Google I/O 2015")
    .setLocation("800 Howard St., San Francisco, CA 94103")
    .setDescription("A chance to hear more about Google's developer products.");

DateTime startDateTime = new DateTime("2015-05-28T09:00:00-07:00");
EventDateTime start = new EventDateTime()
    .setDateTime(startDateTime)
    .setTimeZone("America/Los_Angeles");
event.setStart(start);

DateTime endDateTime = new DateTime("2015-05-28T17:00:00-07:00");
EventDateTime end = new EventDateTime()
    .setDateTime(endDateTime)
    .setTimeZone("America/Los_Angeles");
event.setEnd(end);

String[] recurrence = new String[] {"RRULE:FREQ=DAILY;COUNT=2"};
event.setRecurrence(Arrays.asList(recurrence));

EventAttendee[] attendees = new EventAttendee[] {
    new EventAttendee().setEmail("lpage@example.com"),
    new EventAttendee().setEmail("sbrin@example.com"),
};
event.setAttendees(Arrays.asList(attendees));

EventReminder[] reminderOverrides = new EventReminder[] {
    new EventReminder().setMethod("email").setMinutes(24 * 60),
    new EventReminder().setMethod("popup").setMinutes(10),
};
Event.Reminders reminders = new Event.Reminders()
    .setUseDefault(false)
    .setOverrides(Arrays.asList(reminderOverrides));
event.setReminders(reminders);

String calendarId = "primary";
event = service.events().insert(calendarId, event).execute();
System.out.printf("Event created: %s\n", event.getHtmlLink());
```

```
// Refer to the JavaScript quickstart on how to setup the environment:
// https://developers.google.com/workspace/calendar/quickstart/js
// Change the scope to 'https://www.googleapis.com/auth/calendar' and delete any
// stored credentials.

const event = {
  'summary': 'Google I/O 2015',
  'location': '800 Howard St., San Francisco, CA 94103',
  'description': 'A chance to hear more about Google\'s developer products.',
  'start': {
    'dateTime': '2015-05-28T09:00:00-07:00',
    'timeZone': 'America/Los_Angeles'
  },
  'end': {
    'dateTime': '2015-05-28T17:00:00-07:00',
    'timeZone': 'America/Los_Angeles'
  },
  'recurrence': [
    'RRULE:FREQ=DAILY;COUNT=2'
  ],
  'attendees': [
    {'email': 'lpage@example.com'},
    {'email': 'sbrin@example.com'}
  ],
  'reminders': {
    'useDefault': false,
    'overrides': [
      {'method': 'email', 'minutes': 24 * 60},
      {'method': 'popup', 'minutes': 10}
    ]
  }
};

const request = gapi.client.calendar.events.insert({
  'calendarId': 'primary',
  'resource': event
});

request.execute(function(event) {
  appendPre('Event created: ' + event.htmlLink);
});
```

```
// Refer to the Node.js quickstart on how to setup the environment:
// https://developers.google.com/workspace/calendar/quickstart/node
// Change the scope to 'https://www.googleapis.com/auth/calendar' and delete any
// stored credentials.

const event = {
  'summary': 'Google I/O 2015',
  'location': '800 Howard St., San Francisco, CA 94103',
  'description': 'A chance to hear more about Google\'s developer products.',
  'start': {
    'dateTime': '2015-05-28T09:00:00-07:00',
    'timeZone': 'America/Los_Angeles',
  },
  'end': {
    'dateTime': '2015-05-28T17:00:00-07:00',
    'timeZone': 'America/Los_Angeles',
  },
  'recurrence': [
    'RRULE:FREQ=DAILY;COUNT=2'
  ],
  'attendees': [
    {'email': 'lpage@example.com'},
    {'email': 'sbrin@example.com'},
  ],
  'reminders': {
    'useDefault': false,
    'overrides': [
      {'method': 'email', 'minutes': 24 * 60},
      {'method': 'popup', 'minutes': 10},
    ],
  },
};

calendar.events.insert({
  auth: auth,
  calendarId: 'primary',
  resource: event,
}, function(err, event) {
  if (err) {
    console.log('There was an error contacting the Calendar service: ' + err);
    return;
  }
  console.log('Event created: %s', event.htmlLink);
});
```

```
$event = new Google_Service_Calendar_Event(array(
  'summary' => 'Google I/O 2015',
  'location' => '800 Howard St., San Francisco, CA 94103',
  'description' => 'A chance to hear more about Google\'s developer products.',
  'start' => array(
    'dateTime' => '2015-05-28T09:00:00-07:00',
    'timeZone' => 'America/Los_Angeles',
  ),
  'end' => array(
    'dateTime' => '2015-05-28T17:00:00-07:00',
    'timeZone' => 'America/Los_Angeles',
  ),
  'recurrence' => array(
    'RRULE:FREQ=DAILY;COUNT=2'
  ),
  'attendees' => array(
    array('email' => 'lpage@example.com'),
    array('email' => 'sbrin@example.com'),
  ),
  'reminders' => array(
    'useDefault' => FALSE,
    'overrides' => array(
      array('method' => 'email', 'minutes' => 24 * 60),
      array('method' => 'popup', 'minutes' => 10),
    ),
  ),
));

$calendarId = 'primary';
$event = $service->events->insert($calendarId, $event);
printf('Event created: %s\n', $event->htmlLink);
```

```
# Refer to the Python quickstart on how to setup the environment:
# https://developers.google.com/workspace/calendar/quickstart/python
# Change the scope to 'https://www.googleapis.com/auth/calendar' and delete any
# stored credentials.

event = {
  'summary': 'Google I/O 2015',
  'location': '800 Howard St., San Francisco, CA 94103',
  'description': 'A chance to hear more about Google\'s developer products.',
  'start': {
    'dateTime': '2015-05-28T09:00:00-07:00',
    'timeZone': 'America/Los_Angeles',
  },
  'end': {
    'dateTime': '2015-05-28T17:00:00-07:00',
    'timeZone': 'America/Los_Angeles',
  },
  'recurrence': [
    'RRULE:FREQ=DAILY;COUNT=2'
  ],
  'attendees': [
    {'email': 'lpage@example.com'},
    {'email': 'sbrin@example.com'},
  ],
  'reminders': {
    'useDefault': False,
    'overrides': [
      {'method': 'email', 'minutes': 24 * 60},
      {'method': 'popup', 'minutes': 10},
    ],
  },
}

event = service.events().insert(calendarId='primary', body=event).execute()
print 'Event created: %s' % (event.get('htmlLink'))
```

```
event = Google::Apis::CalendarV3::Event.new(
  summary: 'Google I/O 2015',
  location: '800 Howard St., San Francisco, CA 94103',
  description: 'A chance to hear more about Google\'s developer products.',
  start: Google::Apis::CalendarV3::EventDateTime.new(
    date_time: '2015-05-28T09:00:00-07:00',
    time_zone: 'America/Los_Angeles'
  ),
  end: Google::Apis::CalendarV3::EventDateTime.new(
    date_time: '2015-05-28T17:00:00-07:00',
    time_zone: 'America/Los_Angeles'
  ),
  recurrence: [
    'RRULE:FREQ=DAILY;COUNT=2'
  ],
  attendees: [
    Google::Apis::CalendarV3::EventAttendee.new(
      email: 'lpage@example.com'
    ),
    Google::Apis::CalendarV3::EventAttendee.new(
      email: 'sbrin@example.com'
    )
  ],
  reminders: Google::Apis::CalendarV3::Event::Reminders.new(
    use_default: false,
    overrides: [
      Google::Apis::CalendarV3::EventReminder.new(
        reminder_method: 'email',
        minutes: 24 * 60
      ),
      Google::Apis::CalendarV3::EventReminder.new(
        reminder_method: 'popup',
        minutes: 10
      )
    ]
  )
)

result = client.insert_event('primary', event)
puts "Event created: #{result.html_link}"
```

### Add Drive attachments to events

You can attach [Google Drive](https://drive.google.com/) files such as meeting notes in Docs, budgets in Sheets, presentations in Slides, or any other relevant Google Drive files to your calendar events. You can add the attachment when you create an event with [`events.insert()`](https://developers.google.com/workspace/calendar/v3/reference/events/insert) or later as part of an update such as with [`events.patch()`](https://developers.google.com/workspace/calendar/v3/reference/events/patch)

The two parts of attaching a Google Drive file to an event are:

1.   Get the file `alternateLink` URL, `title`, and `mimeType` from the [Drive API Files resource](https://developers.google.com/workspace/drive/v3/reference/files), typically with the [`files.get()`](https://developers.google.com/workspace/drive/v3/reference/files/get) method.
2.   Create or update an event with the `attachments` fields set in the request body and the `supportsAttachments` parameter set to `true`.

The following code example demonstrates how to update an existing event to add an attachment:

```
public static void addAttachment(Calendar calendarService, Drive driveService, String calendarId,
    String eventId, String fileId) throws IOException {
  File file = driveService.files().get(fileId).execute();
  Event event = calendarService.events().get(calendarId, eventId).execute();

  List<EventAttachment> attachments = event.getAttachments();
  if (attachments == null) {
    attachments = new ArrayList<EventAttachment>();
  }
  attachments.add(new EventAttachment()
      .setFileUrl(file.getAlternateLink())
      .setMimeType(file.getMimeType())
      .setTitle(file.getTitle()));

  Event changes = new Event()
      .setAttachments(attachments);
  calendarService.events().patch(calendarId, eventId, changes)
      .setSupportsAttachments(true)
      .execute();
}
```

```
function addAttachment($calendarService, $driveService, $calendarId, $eventId, $fileId) {
  $file = $driveService->files->get($fileId);
  $event = $calendarService->events->get($calendarId, $eventId);
  $attachments = $event->attachments;

  $attachments[] = array(
    'fileUrl' => $file->alternateLink,
    'mimeType' => $file->mimeType,
    'title' => $file->title
  );
  $changes = new Google_Service_Calendar_Event(array(
    'attachments' => $attachments
  ));

  $calendarService->events->patch($calendarId, $eventId, $changes, array(
    'supportsAttachments' => TRUE
  ));
}
```

```
def add_attachment(calendarService, driveService, calendarId, eventId, fileId):
    file = driveService.files().get(fileId=fileId).execute()
    event = calendarService.events().get(calendarId=calendarId,
                                         eventId=eventId).execute()

    attachments = event.get('attachments', [])
    attachments.append({
        'fileUrl': file['alternateLink'],
        'mimeType': file['mimeType'],
        'title': file['title']
    })

    changes = {
        'attachments': attachments
    }
    calendarService.events().patch(calendarId=calendarId, eventId=eventId,
                                   body=changes,
                                   supportsAttachments=True).execute()
```

### Add video and phone conferences to events

You can associate events with [Hangouts](https://hangouts.google.com/) and [Google Meet](https://meet.google.com/) conferences to allow your users to meet remotely via a phone call or a video call.

The [`conferenceData`](https://developers.google.com/workspace/calendar/v3/reference/events#conferenceData) field can be used to read, copy, and clear existing conference details; it can also be used to request generation of new conferences. To allow creation and modification of conference details, set the `conferenceDataVersion` request parameter to `1`.

There are three types of `conferenceData` currently supported, as denoted by the `conferenceData.conferenceSolution.key.type`:

1.   Hangouts for consumers (`eventHangout`)
2.   Classic Hangouts for Google Workspace users (deprecated; `eventNamedHangout`)
3.   Google Meet (`hangoutsMeet`)

You can learn which conference type is supported for any given calendar of a user by looking at the `conferenceProperties.allowedConferenceSolutionTypes` in the [`calendars`](https://developers.google.com/workspace/calendar/v3/reference/calendars) and [`calendarList`](https://developers.google.com/workspace/calendar/v3/reference/calendarList) collections. You can also learn whether the user prefers to have Hangouts created for all their newly created events by checking the `autoAddHangouts` setting in the [`settings`](https://developers.google.com/workspace/calendar/v3/reference/settings) collection.

Besides the `type`, the `conferenceSolution` also provides the `name` and the `iconUri` fields that you can use to represent the conference solution as shown below:

```
const solution = event.conferenceData.conferenceSolution;

const content = document.getElementById("content");
const text = document.createTextNode("Join " + solution.name);
const icon = document.createElement("img");
icon.src = solution.iconUri;

content.appendChild(icon);
content.appendChild(text);
```

You can create a new conference for an event by providing a `createRequest` with a newly generated `requestId` which can be a random `string`. Conferences are created asynchronously, but you can always check the status of your request to let your users know what’s happening.

For example, to request conference generation for an existing event:

```
const eventPatch = {
  conferenceData: {
    createRequest: {requestId: "7qxalsvy0e"}
  }
};

gapi.client.calendar.events.patch({
  calendarId: "primary",
  eventId: "7cbh8rpc10lrc0ckih9tafss99",
  resource: eventPatch,
  sendUpdates: "all",
  conferenceDataVersion: 1
}).execute(function(event) {
  console.log("Conference created for event: %s", event.htmlLink);
});
```

The immediate response to this call might not yet contain the fully-populated `conferenceData`; this is indicated by a status code of `pending` in the [status](https://developers.google.com/workspace/calendar/v3/reference/events#conferenceData.createRequest.status) field. The status code changes to `success` after the conference information is populated. The `entryPoints` field contains information about which video and phone URIs are available for your users to dial in.

If you wish to schedule multiple Calendar events with the same conference details, you can copy the entire `conferenceData` from one event to another.

Copying is useful in certain situations. For example, suppose you are developing a recruiting application that sets up separate events for the candidate and the interviewer—you want to protect the interviewer’s identity, but you also want to make sure all participants join the same conference call.

Except as otherwise noted, the content of this page is licensed under the [Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/), and code samples are licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0). For details, see the [Google Developers Site Policies](https://developers.google.com/site-policies). Java is a registered trademark of Oracle and/or its affiliates.

Last updated 2025-12-11 UTC.
