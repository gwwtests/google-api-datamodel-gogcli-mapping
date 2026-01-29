Title: Synchronizing Clients with Gmail

URL Source: https://developers.google.com/gmail/api/guides/sync

Published Time: Thu, 11 Dec 2025 17:10:40 GMT

Markdown Content:
Synchronizing Clients with Gmail | Google for Developers
===============
[Skip to main content](https://developers.google.com/gmail/api/guides/sync#main-content)

[![Image 1: Google Workspace](https://fonts.gstatic.com/s/i/productlogos/googleg/v6/16px.svg)](https://developers.google.com/workspace)
*   [Workspace](https://developers.google.com/workspace)

[Home](https://developers.google.com/workspace)[Gmail](https://developers.google.com/workspace/gmail)[All products](https://developers.google.com/workspace/products-menu)

*   Google Workspace apps
*   [Admin console](https://developers.google.com/workspace/admin)
*   [Cloud Search](https://developers.google.com/workspace/cloud-search)
*   [Gmail](https://developers.google.com/workspace/gmail)
*   [Google Calendar](https://developers.google.com/workspace/calendar)
*   [Google Chat](https://developers.google.com/workspace/chat)
*   [Google Classroom](https://developers.google.com/workspace/classroom)
*   [Google Docs](https://developers.google.com/workspace/docs)
*   [Google Drive](https://developers.google.com/workspace/drive)

*   [Google Forms](https://developers.google.com/workspace/forms)
*   [Google Keep](https://developers.google.com/workspace/keep)
*   [Google Meet](https://developers.google.com/workspace/meet)
*   [Google Sheets](https://developers.google.com/workspace/sheets)
*   [Google Sites](https://developers.google.com/workspace/sites)
*   [Google Slides](https://developers.google.com/workspace/slides)
*   [Google Tasks](https://developers.google.com/workspace/tasks)
*   [Google Vault](https://developers.google.com/workspace/vault)

*   Extend, automate & share
*   [Add-ons](https://developers.google.com/workspace/add-ons)
*   [Apps Script](https://developers.google.com/apps-script)
*   [Chat apps](https://developers.google.com/workspace/add-ons/chat)
*   [Drive apps](https://developers.google.com/workspace/drive/api/guides/about-apps)
*   [Marketplace](https://developers.google.com/workspace/marketplace)

[Resources](https://developers.google.com/workspace/resources-menu)

*   Tools
*   [Admin console](https://admin.google.com/)
*   [Apps Script dashboard](https://script.google.com/)
*   [Google Cloud console](https://console.cloud.google.com/workspace-api)
*   [APIs Explorer](https://developers.google.com/workspace/explore)
*   [Card Builder](https://addons.gsuite.google.com/uikit/builder)

*   Training & support
*   [How to get started](https://developers.google.com/workspace/guides/get-started)
*   [Codelabs](https://codelabs.developers.google.com/?product=googleworkspace)
*   [Developer support](https://developers.google.com/workspace/support)

*   Updates
*   [Release notes](https://developers.google.com/workspace/release-notes)
*   [Developer Previews](https://developers.google.com/workspace/preview)
*   [YouTube](https://www.youtube.com/@googleworkspacedevs)
*   [Newsletter](https://developers.google.com/workspace/newsletters)
*   [X (Twitter)](https://twitter.com/workspacedevs)
*   [Blog](https://developers.googleblog.com/search/?query=Google+Workspace)

/

*   [English](https://developers.google.com/gmail/api/guides/sync)
*   [Deutsch](https://developers.google.com/gmail/api/guides/sync)
*   [Español](https://developers.google.com/gmail/api/guides/sync)
*   [Español – América Latina](https://developers.google.com/gmail/api/guides/sync)
*   [Français](https://developers.google.com/gmail/api/guides/sync)
*   [Indonesia](https://developers.google.com/gmail/api/guides/sync)
*   [Italiano](https://developers.google.com/gmail/api/guides/sync)
*   [Polski](https://developers.google.com/gmail/api/guides/sync)
*   [Português – Brasil](https://developers.google.com/gmail/api/guides/sync)
*   [Tiếng Việt](https://developers.google.com/gmail/api/guides/sync)
*   [Türkçe](https://developers.google.com/gmail/api/guides/sync)
*   [Русский](https://developers.google.com/gmail/api/guides/sync)
*   [עברית](https://developers.google.com/gmail/api/guides/sync)
*   [العربيّة](https://developers.google.com/gmail/api/guides/sync)
*   [فارسی](https://developers.google.com/gmail/api/guides/sync)
*   [हिंदी](https://developers.google.com/gmail/api/guides/sync)
*   [বাংলা](https://developers.google.com/gmail/api/guides/sync)
*   [ภาษาไทย](https://developers.google.com/gmail/api/guides/sync)
*   [中文 – 简体](https://developers.google.com/gmail/api/guides/sync)
*   [中文 – 繁體](https://developers.google.com/gmail/api/guides/sync)
*   [日本語](https://developers.google.com/gmail/api/guides/sync)
*   [한국어](https://developers.google.com/gmail/api/guides/sync)

Sign in

*   [Gmail](https://developers.google.com/workspace/gmail)

[Overview](https://developers.google.com/workspace/gmail)[Guides](https://developers.google.com/workspace/gmail/api/guides)[Reference](https://developers.google.com/workspace/gmail/api/reference/rest)[Samples](https://developers.google.com/workspace/gmail/api/samples)[Support](https://developers.google.com/workspace/gmail/api/support)

[![Image 2: Google Workspace](https://fonts.gstatic.com/s/i/productlogos/googleg/v6/16px.svg)](https://developers.google.com/workspace)
*   [Workspace](https://developers.google.com/workspace)

*   [Home](https://developers.google.com/workspace)
*   [Gmail](https://developers.google.com/workspace/gmail)
    *   [Overview](https://developers.google.com/workspace/gmail)
    *   [Guides](https://developers.google.com/workspace/gmail/api/guides)
    *   [Reference](https://developers.google.com/workspace/gmail/api/reference/rest)
    *   [Samples](https://developers.google.com/workspace/gmail/api/samples)
    *   [Support](https://developers.google.com/workspace/gmail/api/support)

*   [All products](https://developers.google.com/workspace/products-menu)
    *    More 

*   [Resources](https://developers.google.com/workspace/resources-menu)
    *    More 

*   Get started 
*   [Gmail API overview](https://developers.google.com/workspace/gmail/api/guides)
*   [Get started with Google Workspace](https://developers.google.com/workspace/guides/get-started)
*   [Configure OAuth consent](https://developers.google.com/workspace/guides/configure-oauth-consent)
*   Gmail API 
*   
[](https://developers.google.com/gmail/api/guides/sync)Authentication & authorization 
    *   [Choose scopes](https://developers.google.com/workspace/gmail/api/auth/scopes)
    *   [Implement server-side authorization](https://developers.google.com/workspace/gmail/api/auth/web-server)

*   
[](https://developers.google.com/gmail/api/guides/sync)Quickstarts 
    *   [JavaScript](https://developers.google.com/workspace/gmail/api/quickstart/js)
    *   [Java](https://developers.google.com/workspace/gmail/api/quickstart/java)
    *   [Python](https://developers.google.com/workspace/gmail/api/quickstart/python)
    *   [Apps Script](https://developers.google.com/workspace/gmail/api/quickstart/apps-script)
    *   [Go](https://developers.google.com/workspace/gmail/api/quickstart/go)
    *   [Node.js](https://developers.google.com/workspace/gmail/api/quickstart/nodejs)

*   
[](https://developers.google.com/gmail/api/guides/sync)Create & send mail 
    *   [Create drafts](https://developers.google.com/workspace/gmail/api/guides/drafts)
    *   [Send email](https://developers.google.com/workspace/gmail/api/guides/sending)
    *   [Upload attachments](https://developers.google.com/workspace/gmail/api/guides/uploads)

*   
[](https://developers.google.com/gmail/api/guides/sync)Manage mailboxes 
    *   [Threads](https://developers.google.com/workspace/gmail/api/guides/threads)
    *   [Labels](https://developers.google.com/workspace/gmail/api/guides/labels)
    *   [Search for messages](https://developers.google.com/workspace/gmail/api/guides/filtering)
    *   [List messages](https://developers.google.com/workspace/gmail/api/guides/list-messages)
    *   [Sync a mail client](https://developers.google.com/workspace/gmail/api/guides/sync)
    *   [Receive push notifications](https://developers.google.com/workspace/gmail/api/guides/push)

*   
[](https://developers.google.com/gmail/api/guides/sync)Manage settings 
    *   [Aliases & signatures](https://developers.google.com/workspace/gmail/api/guides/alias_and_signature_settings)
    *   [Forwarding](https://developers.google.com/workspace/gmail/api/guides/forwarding_settings)
    *   [Filters](https://developers.google.com/workspace/gmail/api/guides/filter_settings)
    *   [Vacation](https://developers.google.com/workspace/gmail/api/guides/vacation_settings)
    *   [S/MIME certificates](https://developers.google.com/workspace/gmail/api/guides/smime_certs)
    *   [POP & IMAP](https://developers.google.com/workspace/gmail/api/guides/pop_imap_settings)
    *   [Delegates](https://developers.google.com/workspace/gmail/api/guides/delegate_settings)
    *   [Language](https://developers.google.com/workspace/gmail/api/guides/language-settings)
    *   [Inbox feed](https://developers.google.com/workspace/gmail/gmail_inbox_feed)

*   
[](https://developers.google.com/gmail/api/guides/sync)Best practices 
    *   [Batch requests](https://developers.google.com/workspace/gmail/api/guides/batch)
    *   [Performance tips](https://developers.google.com/workspace/gmail/api/guides/performance)
    *   [Resolve errors](https://developers.google.com/workspace/gmail/api/guides/handle-errors)

*   
[](https://developers.google.com/gmail/api/guides/sync)Troubleshoot 
    *   [Troubleshoot authentication & authorization](https://developers.google.com/workspace/gmail/api/troubleshoot-authentication-authorization)

*   
[](https://developers.google.com/gmail/api/guides/sync)Migrate from a previous API 
    *   [Email Settings API](https://developers.google.com/workspace/gmail/api/guides/migrate-from-email-settings)

*   IMAP for Gmail 
*   [Overview](https://developers.google.com/workspace/gmail/imap/imap-smtp)
*   [XOAUTH2 Mechanism](https://developers.google.com/workspace/gmail/imap/xoauth2-protocol)
*   [Libraries and Samples](https://developers.google.com/workspace/gmail/imap/xoauth2-libraries)
*   [IMAP Extensions](https://developers.google.com/workspace/gmail/imap/imap-extensions)
*   Postmaster Tools API 
*   [Overview](https://developers.google.com/workspace/gmail/postmaster)
*   
[](https://developers.google.com/gmail/api/guides/sync)Quickstarts 
    *   [Java](https://developers.google.com/workspace/gmail/postmaster/quickstart/java)
    *   [Python](https://developers.google.com/workspace/gmail/postmaster/quickstart/python)

*   
[](https://developers.google.com/gmail/api/guides/sync)How do I... 
    *   [Set up authentication domains](https://developers.google.com/workspace/gmail/postmaster/guides/domain)
    *   [Set up the API](https://developers.google.com/workspace/gmail/postmaster/guides/setup)
    *   [Verify authentication domains](https://developers.google.com/workspace/gmail/postmaster/guides/verify-domain)
    *   [Retrieve email metrics](https://developers.google.com/workspace/gmail/postmaster/guides/retrieve-metrics)

*   
[](https://developers.google.com/gmail/api/guides/sync)Troubleshoot 
    *   [Troubleshoot authentication & authorization](https://developers.google.com/workspace/gmail/postmaster/troubleshoot-authentication-authorization)

*   Sender resources 
*   
[](https://developers.google.com/gmail/api/guides/sync)AMP for Gmail 
    *   [Overview](https://developers.google.com/workspace/gmail/ampemail)
    *   [AMP developer guides](https://amp.dev/about/email.html)
    *   [AMP reference](https://amp.dev/documentation/components/?format=email)
    *   [Authenticate requests](https://developers.google.com/workspace/gmail/ampemail/authenticating-requests)
    *   [Security requirements](https://developers.google.com/workspace/gmail/ampemail/security-requirements)
    *   [Test dynamic email](https://developers.google.com/workspace/gmail/ampemail/testing-dynamic-email)
    *   [Debug dynamic email](https://developers.google.com/workspace/gmail/ampemail/debugging-dynamic-email)
    *   [Register with Google](https://developers.google.com/workspace/gmail/ampemail/register)
    *   [Supported platforms](https://developers.google.com/workspace/gmail/ampemail/supported-platforms)
    *   [Tips and known limitations](https://developers.google.com/workspace/gmail/ampemail/tips)

*   [Bulk sender guidelines](https://support.google.com/mail/answer/81126)
*   [Email CSS](https://developers.google.com/workspace/gmail/design/css)
*   
[](https://developers.google.com/gmail/api/guides/sync)Email markup 
    *   [Overview](https://developers.google.com/workspace/gmail/markup/overview)
    *   [Get Started](https://developers.google.com/workspace/gmail/markup/getting-started)
    *   
[](https://developers.google.com/gmail/api/guides/sync)Actions and Highlights 
        *   [What Are Actions?](https://developers.google.com/workspace/gmail/markup/actions/actions-overview)
        *   [What Are Highlights?](https://developers.google.com/workspace/gmail/markup/highlights)
        *   [Declare Actions](https://developers.google.com/workspace/gmail/markup/actions/declaring-actions)
        *   [Handle Action Requests](https://developers.google.com/workspace/gmail/markup/actions/handling-action-requests)

    *   
[](https://developers.google.com/gmail/api/guides/sync)Secure Actions 
        *   [Overview](https://developers.google.com/workspace/gmail/markup/actions/securing-actions)
        *   [Limited-Use Access Tokens](https://developers.google.com/workspace/gmail/markup/actions/limited-use-access-tokens)
        *   [Verify Bearer Tokens](https://developers.google.com/workspace/gmail/markup/actions/verifying-bearer-tokens)

    *   
[](https://developers.google.com/gmail/api/guides/sync)Tutorials 
        *   [Apps Script Quickstart](https://developers.google.com/workspace/gmail/markup/apps-script-tutorial)
        *   [App Engine End-to-End](https://developers.google.com/workspace/gmail/markup/actions/end-to-end-example)
        *   [Test Your Schemas](https://developers.google.com/workspace/gmail/markup/testing-your-schema)

    *   [Register with Google](https://developers.google.com/workspace/gmail/markup/registering-with-google)

*   
[](https://developers.google.com/gmail/api/guides/sync)Email promotions 
    *   [Overview](https://developers.google.com/workspace/gmail/promotab)
    *   [Get started](https://developers.google.com/workspace/gmail/promotab/overview)
    *   [Preview annotations](https://developers.google.com/workspace/gmail/promotab/preview)
    *   [Best Practices](https://developers.google.com/workspace/gmail/promotab/best-practices)
    *   [Troubleshooting](https://developers.google.com/workspace/gmail/promotab/troubleshooting)
    *   [FAQ](https://developers.google.com/workspace/gmail/promotab/faq)

*   
[](https://developers.google.com/gmail/api/guides/sync)Email reactions 
    *   [Overview](https://developers.google.com/workspace/gmail/reactions/format)
    *   [Examples](https://developers.google.com/workspace/gmail/reactions/examples)

*   Android content provider 
*   [Overview](https://developers.google.com/workspace/gmail/android)
*   [Download a sample app](https://developers.google.com/static/workspace/gmail/android/android-gmail-api-sample.tar.gz)
*   [Content provider basics](https://developer.android.com/guide/topics/providers/content-provider-basics.html)
*   Extend & automate 
*   [Add-ons](https://developers.google.com/workspace/add-ons/gmail)
*   [Apps Script](https://developers.google.com/apps-script/reference/gmail)

*    Google Workspace apps 
*   [Admin console](https://developers.google.com/workspace/admin)
*   [Cloud Search](https://developers.google.com/workspace/cloud-search)
*   [Gmail](https://developers.google.com/workspace/gmail)
*   [Google Calendar](https://developers.google.com/workspace/calendar)
*   [Google Chat](https://developers.google.com/workspace/chat)
*   [Google Classroom](https://developers.google.com/workspace/classroom)
*   [Google Docs](https://developers.google.com/workspace/docs)
*   [Google Drive](https://developers.google.com/workspace/drive)

*   [Google Forms](https://developers.google.com/workspace/forms)
*   [Google Keep](https://developers.google.com/workspace/keep)
*   [Google Meet](https://developers.google.com/workspace/meet)
*   [Google Sheets](https://developers.google.com/workspace/sheets)
*   [Google Sites](https://developers.google.com/workspace/sites)
*   [Google Slides](https://developers.google.com/workspace/slides)
*   [Google Tasks](https://developers.google.com/workspace/tasks)
*   [Google Vault](https://developers.google.com/workspace/vault)
*    Extend, automate & share 
*   [Add-ons](https://developers.google.com/workspace/add-ons)
*   [Apps Script](https://developers.google.com/apps-script)
*   [Chat apps](https://developers.google.com/workspace/add-ons/chat)
*   [Drive apps](https://developers.google.com/workspace/drive/api/guides/about-apps)
*   [Marketplace](https://developers.google.com/workspace/marketplace)

*    Tools 
*   [Admin console](https://admin.google.com/)
*   [Apps Script dashboard](https://script.google.com/)
*   [Google Cloud console](https://console.cloud.google.com/workspace-api)
*   [APIs Explorer](https://developers.google.com/workspace/explore)
*   [Card Builder](https://addons.gsuite.google.com/uikit/builder)
*    Training & support 
*   [How to get started](https://developers.google.com/workspace/guides/get-started)
*   [Codelabs](https://codelabs.developers.google.com/?product=googleworkspace)
*   [Developer support](https://developers.google.com/workspace/support)
*    Updates 
*   [Release notes](https://developers.google.com/workspace/release-notes)
*   [Developer Previews](https://developers.google.com/workspace/preview)
*   [YouTube](https://www.youtube.com/@googleworkspacedevs)
*   [Newsletter](https://developers.google.com/workspace/newsletters)
*   [X (Twitter)](https://twitter.com/workspacedevs)
*   [Blog](https://developers.googleblog.com/search/?query=Google+Workspace)

*   [Home](https://developers.google.com/)
*    [Google Workspace](https://developers.google.com/workspace)
*    [Gmail](https://developers.google.com/workspace/gmail)
*    [Guides](https://developers.google.com/workspace/gmail/api/guides)

 Send feedback 
Synchronizing Clients with Gmail Stay organized with collections  Save and categorize content based on your preferences.
========================================================================================================================

Keeping your client synchronized with Gmail is important for most application scenarios. There are two overall synchronization scenarios: full synchronization and partial synchronization. Full synchronization is required the first time your client connects to Gmail and in some other rare scenarios. If your client has recently synchronized, partial synchronization is a lighter-weight alternative to a full sync. You can also use [push notifications](https://developers.google.com/workspace/gmail/api/guides/push) to trigger partial synchronization in real-time and only when necessary, thereby avoiding needless polling.

Contents
--------

[](https://developers.google.com/gmail/api/guides/sync)

Full synchronization
--------------------

The first time your application connects to Gmail, or if partial synchronization is not available, you must perform a full sync. In a full sync operation, your application should retrieve and store as many of the most recent messages or threads as are necessary for your purpose. For example, if your application displays a list of recent messages, you may wish to retrieve and cache enough messages to allow for a responsive interface if the user scrolls beyond the first several messages displayed. The general procedure for performing a full sync operation is as follows:

1.   Call [`messages.list`](https://developers.google.com/workspace/gmail/api/v1/reference/users/messages/list) to retrieve the first page of message IDs.
2.   Create a [batch request](https://developers.google.com/workspace/gmail/api/guides/batch) of [`messages.get`](https://developers.google.com/workspace/gmail/api/v1/reference/users/messages/get) requests for each of the messages returned by the list request. If your application displays message contents, you should use `format=FULL` or `format=RAW` the first time your application retrieves a message and cache the results to avoid additional retrieval operations. If you are retrieving a previously cached message, you should use `format=MINIMAL` to reduce the size of the response as only the `labelIds` may change.
3.   Merge the updates into your cached results. Your application should store the `historyId` of the most recent message (the first message in the `list` response) for future partial synchronization.

**Note:** You can also perform synchronization using the equivalent [`Threads` resource](https://developers.google.com/workspace/gmail/api/v1/reference/users/threads) methods. This may be advantageous if your application primarily works with threads or only requires message metadata.
[](https://developers.google.com/gmail/api/guides/sync)

Partial synchronization
-----------------------

If your application has synchronized recently, you can perform a partial sync using the [`history.list`](https://developers.google.com/workspace/gmail/api/v1/reference/users/history/list) method to return all history records newer than the `startHistoryId` you specify in your request. History records provide message IDs and type of change for each message, such as message added, deleted, or labels modified since the time of the `startHistoryId`. You can obtain and store the `historyId` of the most recent message from a full or partial sync to provide as a `startHistoryId` for future partial synchronization operations.

[](https://developers.google.com/gmail/api/guides/sync)

Limitations
-----------

History records are typically available for at least one week and often longer. However, the time period for which records are available may be significantly less and records may sometimes be unavailable in rare cases. If the `startHistoryId` supplied by your client is outside the available range of history records, the API returns an `HTTP 404` error response. In this case, your client must perform a full sync as described in the previous section.

 Send feedback 
Except as otherwise noted, the content of this page is licensed under the [Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/), and code samples are licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0). For details, see the [Google Developers Site Policies](https://developers.google.com/site-policies). Java is a registered trademark of Oracle and/or its affiliates.

Last updated 2025-12-11 UTC.

 Need to tell us more?  [[["Easy to understand","easyToUnderstand","thumb-up"],["Solved my problem","solvedMyProblem","thumb-up"],["Other","otherUp","thumb-up"]],[["Missing the information I need","missingTheInformationINeed","thumb-down"],["Too complicated / too many steps","tooComplicatedTooManySteps","thumb-down"],["Out of date","outOfDate","thumb-down"],["Samples / code issue","samplesCodeIssue","thumb-down"],["Other","otherDown","thumb-down"]],["Last updated 2025-12-11 UTC."],[],[]] 

*   [![Image 3: Blog](https://www.gstatic.com/images/branding/product/2x/google_cloud_64dp.png) Blog](https://developers.googleblog.com/search/?query=Google+Workspace)Read the Google Workspace Developers blog 
*   [![Image 4: X (Twitter)](https://developers.google.com/static/site-assets/logo-x.svg) X (Twitter)](https://twitter.com/workspacedevs)Follow @workspacedevs on X (Twitter) 
*   [![Image 5: Code Samples](https://developers.google.com/static/site-assets/logo-github.svg) Code Samples](https://github.com/googleworkspace)Explore our sample apps or copy them to build your own 
*   [![Image 6: Codelabs](https://developers.google.com/static/site-assets/developers-logo-color.svg) Codelabs](https://codelabs.developers.google.com/?product=googleworkspace)Try a guided, hands-on coding experience 
*   [![Image 7: Videos](https://developers.google.com/static/site-assets/logo-youtube.svg) Videos](https://www.youtube.com/channel/UCUcg6az6etU_gRtZVAhBXaw)Subscribe to our YouTube channel 

*   ### Google Workspace for Developers

    *   [Platform overview](https://developers.google.com/workspace)
    *   [Developer products](https://developers.google.com/workspace/products)
    *   [Release notes](https://developers.google.com/workspace/release-notes)
    *   [Developer support](https://developers.google.com/workspace/support)
    *   [Terms of Service](https://developers.google.com/workspace/terms)

*   ### Tools

    *   [Admin console](https://admin.google.com/)
    *   [Apps Script Dashboard](https://script.google.com/)
    *   [Google Cloud console](https://console.cloud.google.com/workspace-api)
    *   [APIs Explorer](https://developers.google.com/workspace/explore)

*   ### Connect

    *   [Blog](https://developers.googleblog.com/search/?query=Google+Workspace)
    *   [Newsletter](https://developers.google.com/workspace/newsletters)
    *   [X (Twitter)](https://twitter.com/workspacedevs)
    *   [YouTube](https://www.youtube.com/channel/UCUcg6az6etU_gRtZVAhBXaw)

[![Image 8: Google Developers](https://www.gstatic.com/devrel-devsite/prod/v6dcfc5a6ab74baade852b535c8a876ff20ade102b870fd5f49da5da2dbf570bd/developers/images/lockup-google-for-developers.svg)](https://developers.google.com/)
*   [Android](https://developer.android.com/)
*   [Chrome](https://developer.chrome.com/home)
*   [Firebase](https://firebase.google.com/)
*   [Google Cloud Platform](https://cloud.google.com/)
*   [Google AI](https://ai.google.dev/)
*   [All products](https://developers.google.com/products)

*   [Terms](https://developers.google.com/terms/site-terms)
*   [Privacy](https://policies.google.com/privacy)
*   [Manage cookies](https://developers.google.com/gmail/api/guides/sync#)

*   [English](https://developers.google.com/gmail/api/guides/sync)
*   [Deutsch](https://developers.google.com/gmail/api/guides/sync)
*   [Español](https://developers.google.com/gmail/api/guides/sync)
*   [Español – América Latina](https://developers.google.com/gmail/api/guides/sync)
*   [Français](https://developers.google.com/gmail/api/guides/sync)
*   [Indonesia](https://developers.google.com/gmail/api/guides/sync)
*   [Italiano](https://developers.google.com/gmail/api/guides/sync)
*   [Polski](https://developers.google.com/gmail/api/guides/sync)
*   [Português – Brasil](https://developers.google.com/gmail/api/guides/sync)
*   [Tiếng Việt](https://developers.google.com/gmail/api/guides/sync)
*   [Türkçe](https://developers.google.com/gmail/api/guides/sync)
*   [Русский](https://developers.google.com/gmail/api/guides/sync)
*   [עברית](https://developers.google.com/gmail/api/guides/sync)
*   [العربيّة](https://developers.google.com/gmail/api/guides/sync)
*   [فارسی](https://developers.google.com/gmail/api/guides/sync)
*   [हिंदी](https://developers.google.com/gmail/api/guides/sync)
*   [বাংলা](https://developers.google.com/gmail/api/guides/sync)
*   [ภาษาไทย](https://developers.google.com/gmail/api/guides/sync)
*   [中文 – 简体](https://developers.google.com/gmail/api/guides/sync)
*   [中文 – 繁體](https://developers.google.com/gmail/api/guides/sync)
*   [日本語](https://developers.google.com/gmail/api/guides/sync)
*   [한국어](https://developers.google.com/gmail/api/guides/sync)
