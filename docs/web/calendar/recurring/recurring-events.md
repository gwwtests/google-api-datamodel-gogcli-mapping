Title: Recurring events

URL Source: https://developers.google.com/calendar/api/guides/recurringevents

Markdown Content:
This document describes how to work with [recurring events](https://developers.google.com/workspace/calendar/concepts/events-calendars#recurring_events) and their instances.

Create recurring events
-----------------------

Creating recurring events is similar to [creating](https://developers.google.com/workspace/calendar/v3/reference/events/insert) a regular (single) event with the [`event`](https://developers.google.com/workspace/calendar/v3/reference/events) resource's [`recurrence`](https://developers.google.com/workspace/calendar/v3/reference/events#recurrence) field set.

POST /calendar/v3/calendars/primary/events
...

{
 "summary": "Appointment",
 "location": "Somewhere",
 "start": {
 "dateTime": "2011-06-03T10:00:00.000-07:00",
 "timeZone": "America/Los_Angeles"
 },
 "end": {
 "dateTime": "2011-06-03T10:25:00.000-07:00",
 "timeZone": "America/Los_Angeles"
 },
 "recurrence": [
 "RRULE:FREQ=WEEKLY;UNTIL=20110701T170000Z",
 ],
 "attendees": [
 {
 "email": "attendeeEmail",
 # Other attendee's data...
 },
 # ...
 ],
}Event event = new Event();

event.setSummary("Appointment");
event.setLocation("Somewhere");

ArrayList<EventAttendee> attendees = new ArrayList<EventAttendee>();
attendees.add(new EventAttendee().setEmail("attendeeEmail"));
// ...
event.setAttendees(attendees);

DateTime start = DateTime.parseRfc3339("2011-06-03T10:00:00.000-07:00");
DateTime end = DateTime.parseRfc3339("2011-06-03T10:25:00.000-07:00");
event.setStart(new EventDateTime().setDateTime(start).setTimeZone("America/Los_Angeles"));
event.setEnd(new EventDateTime().setDateTime(end).setTimeZone("America/Los_Angeles"));
event.setRecurrence(Arrays.asList("RRULE:FREQ=WEEKLY;UNTIL=20110701T170000Z"));

Event recurringEvent = service.events().insert("primary", event).execute();

System.out.println(createdEvent.getId());Event event = new Event()
    {
      Summary = "Appointment",
      Location = "Somewhere",
      Start = new EventDateTime() {
          DateTime = new DateTime("2011-06-03T10:00:00.000:-07:00")
          TimeZone = "America/Los_Angeles"
      },
      End = new EventDateTime() {
          DateTime = new DateTime("2011-06-03T10:25:00.000:-07:00")
          TimeZone = "America/Los_Angeles"
      },
      Recurrence = new String[] {
          "RRULE:FREQ=WEEKLY;UNTIL=20110701T170000Z"
      },
      Attendees = new List<EventAttendee>()
          {
            new EventAttendee() { Email: "attendeeEmail" },
            // ...
          }
    };

Event recurringEvent = service.Events.Insert(event, "primary").Fetch();

Console.WriteLine(recurringEvent.Id);event = {
  'summary': 'Appointment',
  'location': 'Somewhere',
  'start': {
    'dateTime': '2011-06-03T10:00:00.000-07:00',
    'timeZone': 'America/Los_Angeles'
  },
  'end': {
    'dateTime': '2011-06-03T10:25:00.000-07:00',
    'timeZone': 'America/Los_Angeles'
  },
  'recurrence': [
    'RRULE:FREQ=WEEKLY;UNTIL=20110701T170000Z',
  ],
  'attendees': [
    {
      'email': 'attendeeEmail',
      # Other attendee's data...
    },
    # ...
  ],
}

recurring_event = service.events().insert(calendarId='primary', body=event).execute()

print recurring_event['id']$event = new Google_Service_Calendar_Event();
$event->setSummary('Appointment');
$event->setLocation('Somewhere');
$start = new Google_Service_Calendar_EventDateTime();
$start->setDateTime('2011-06-03T10:00:00.000-07:00');
$start->setTimeZone('America/Los_Angeles');
$event->setStart($start);
$end = new Google_Service_Calendar_EventDateTime();
$end->setDateTime('2011-06-03T10:25:00.000-07:00');
$end->setTimeZone('America/Los_Angeles');
$event->setEnd($end);
$event->setRecurrence(array('RRULE:FREQ=WEEKLY;UNTIL=20110701T170000Z'));
$attendee1 = new Google_Service_Calendar_EventAttendee();
$attendee1->setEmail('attendeeEmail');
// ...
$attendees = array($attendee1,
 // ...
 );
$event->attendees = $attendees;
$recurringEvent = $service->events->insert('primary', $event);

echo $recurringEvent->getId();event = Google::Apis::CalendarV3::Event.new(
 summary: 'Appointment',
 location: 'Somewhere',
 start: {
 date_time: '2011-06-03T10:00:00.000-07:00',
 time_zone: 'America/Los_Angeles'
 },
 end: {
 date_time: '2011-06-03T10:25:00.000-07:00',
 time_zone: 'America/Los_Angeles'
 },
 recurrence: ['RRULE:FREQ=WEEKLY;UNTIL=20110701T170000Z']
 attendees: [
 {
 email: 'attendeeEmail'
 },
 #...
 ]
)
response = client.insert_event('primary', event)
print response.id
Access instances
----------------

To see all the [instances](https://developers.google.com/workspace/calendar/concepts/events-calendars#instances_and_exceptions) of a given recurring event you can use the [events.instances()](https://developers.google.com/workspace/calendar/v3/reference/events/instances) request.

The [`events.list()`](https://developers.google.com/workspace/calendar/v3/reference/events/list) request by default only returns single events, recurring events, and [exceptions](https://developers.google.com/workspace/calendar/concepts/events-calendars#instances_and_exceptions); instances that are not exceptions are not returned. If the [`singleEvents`](https://developers.google.com/workspace/calendar/v3/reference/events/list#singleEvents) parameter is set `true` then all individual instances appear in the result, but underlying recurring events don't. When a user who has free/busy permissions queries `events.list()`, it behaves as if `singleEvent` is `true`. For more information about access control list rules, see [Acl](https://developers.google.com/calendar/v3/reference/acl).

Individual instances are similar to single events. Unlike their parent recurring events, instances do not have the [`recurrence`](https://developers.google.com/workspace/calendar/v3/reference/events#recurrence) field set.

The following event fields are specific to instances:

*   [`recurringEventId`](https://developers.google.com/workspace/calendar/v3/reference/events#recurringEventId) — the ID of the parent recurring event this instance belongs to
*   [`originalStartTime`](https://developers.google.com/workspace/calendar/v3/reference/events#originalStartTime) — the time this instance starts according to the recurrence data in the parent recurring event. This can be different from the actual [`start`](https://developers.google.com/workspace/calendar/v3/reference/events#start) time if the instance was rescheduled. It uniquely identifies the instance within the recurring event series even if the instance was moved.

Modify or delete instances
--------------------------

To modify a single instance (creating an exception), client applications must first retrieve the instance and then update it by sending an authorized PUT request to the instance edit URL with updated data in the body. The URL is of the form:

```
https://www.googleapis.com/calendar/v3/calendars/calendarId/events/instanceId
```

Use appropriate values in place of calendarId and instanceId.

**Note:** The special calendarId value `primary` can be used to refer to the authenticated user's primary calendar.

Upon success, the server responds with an HTTP 200 OK status code with the updated instance. The following example shows how to cancel an instance of a recurring event.

PUT /calendar/v3/calendars/primary/events/instanceId
...

{
  "kind": "calendar#event",
  "id": "instanceId",
  "etag": "instanceEtag",
  "status": "cancelled",
  "htmlLink": "https://www.google.com/calendar/event?eid=instanceEid",
  "created": "2011-05-23T22:27:01.000Z",
  "updated": "2011-05-23T22:27:01.000Z",
  "summary": "Recurring event",
  "location": "Somewhere",
  "creator": {
    "email": "userEmail"
  },
  "recurringEventId": "recurringEventId",
  "originalStartTime": "2011-06-03T10:00:00.000-07:00",
  "organizer": {
    "email": "userEmail",
    "displayName": "userDisplayName"
  },
  "start": {
    "dateTime": "2011-06-03T10:00:00.000-07:00",
    "timeZone": "America/Los_Angeles"
  },
  "end": {
    "dateTime": "2011-06-03T10:25:00.000-07:00",
    "timeZone": "America/Los_Angeles"
  },
  "iCalUID": "eventUID",
  "sequence": 0,
  "attendees": [
    {
      "email": "attendeeEmail",
      "displayName": "attendeeDisplayName",
      "responseStatus": "needsAction"
    },
    # ...
    {
      "email": "userEmail",
      "displayName": "userDisplayName",
      "responseStatus": "accepted",
      "organizer": true,
      "self": true
    }
  ],
  "guestsCanInviteOthers": false,
  "guestsCanSeeOtherGuests": false,
  "reminders": {
    "useDefault": true
  }
}// First retrieve the instances from the API.
Events instances = service.events().instances("primary", "recurringEventId").execute();

// Select the instance to cancel.
Event instance = instances.getItems().get(0);
instance.setStatus("cancelled");

Event updatedInstance = service.events().update("primary", instance.getId(), instance).execute();

// Print the updated date.
System.out.println(updatedInstance.getUpdated());// First retrieve the instances from the API.
Events instances = service.Events.Instances("primary", "recurringEventId").Fetch();

// Select the instance to cancel.
Event instance = instances.Items[0];
instance.Status = "cancelled";

Event updatedInstance = service.Events.Update(instance, "primary", instance.Id).Fetch();

// Print the updated date.
Console.WriteLine(updatedInstance.Updated);# First retrieve the instances from the API.
instances = service.events().instances(calendarId='primary', eventId='recurringEventId').execute()

# Select the instance to cancel.
instance = instances['items'][0]
instance['status'] = 'cancelled'

updated_instance = service.events().update(calendarId='primary', eventId=instance['id'], body=instance).execute()

# Print the updated date.
print updated_instance['updated']$events = $service->events->instances("primary", "eventId");

// Select the instance to cancel.
$instance = $events->getItems()[0];
$instance->setStatus('cancelled');

$updatedInstance = $service->events->update('primary', $instance->getId(), $instance);

// Print the updated date.
echo $updatedInstance->getUpdated();# First retrieve the instances from the API.
instances = client.list_event_instances('primary', 'recurringEventId')

# Select the instance to cancel.
instance = instances.items[0]
instance.status = 'cancelled'

response = client.update_event('primary', instance.id, instance)
print response.updated
Modify all following instances
------------------------------

In order to change all the instances of a recurring event on or after a given (target) instance, you must make two separate API requests. These requests split the original recurring event into two: the original one which retains the instances without the change and the new recurring event having instances where the change is applied:

1.   Call [`events.update()`](https://developers.google.com/workspace/calendar/v3/reference/events/update) to trim the original recurring event of the instances to be updated. Do this by setting the `UNTIL` component of the `RRULE` to point before the start time of the first target instance. Alternatively, you can set the`COUNT` component instead of `UNTIL`. 
2.   Call [`events.insert()`](https://developers.google.com/workspace/calendar/v3/reference/events/insert) to create a new recurring event with all the same data as the original, except for the change you are attempting to make. The new recurring event must have the start time of the target instance. 

This example shows how to change the location to "Somewhere else", starting from the third instance of the recurring event from the previous examples.

# Updating the original recurring event to trim the instance list:

PUT /calendar/v3/calendars/primary/events/recurringEventId
...

{
 "summary": "Appointment",
 "location": "Somewhere",
 "start": {
 "dateTime": "2011-06-03T10:00:00.000-07:00",
 "timeZone": "America/Los_Angeles"
 },
 "end": {
 "dateTime": "2011-06-03T10:25:00.000-07:00",
 "timeZone": "America/Los_Angeles"
 },
 "recurrence": [
 "RRULE:FREQ=WEEKLY;UNTIL=20110617T065959Z",
 ],
 "attendees": [
 {
 "email": "attendeeEmail",
 # Other attendee's data...
 },
 # ...
 ],
}

# Creating a new recurring event with the change applied:

POST /calendar/v3/calendars/primary/events
...

{
 "summary": "Appointment",
 "location": "Somewhere else",
 "start": {
 "dateTime": "2011-06-17T10:00:00.000-07:00",
 "timeZone": "America/Los_Angeles"
 },
 "end": {
 "dateTime": "2011-06-17T10:25:00.000-07:00",
 "timeZone": "America/Los_Angeles"
 },
 "recurrence": [
 "RRULE:FREQ=WEEKLY;UNTIL=20110617T065959Z",
 ],
 "attendees": [
 {
 "email": "attendeeEmail",
 # Other attendee's data...
 },
 # ...
 ],
}
