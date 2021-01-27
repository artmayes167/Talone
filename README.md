# Talone

< Note: The file structure is in flux, because I am working on defining an organic flow for engineers. This is  a functional core for communications.>

The purpose of this app is to take this core functionality, and partner with community organizations to build out tools that fit their needs, organically.  A successful tool would, in my current estimation, be sold as an add-on, and the profits split with the community that initiated and co-developed the tool.

Currently, the backend will know users by their email (used to register), a unique handle they create, and a unique ID created by the backend.

This communications tool would be embedded in a community account.  Requirements to join the community would be managed by community managers, with a creation management tool TBD.

Cities and localities are used as proxies for eventual geofenced polygons-- the list needs to expand by determined localities, to serve as reference points.  As events unfold, I want to establish a convention that allows self-defining communities to name themselves without restriction, perhaps by adding a server-level name extension that will indicate coordinates of a key point.  Those names would then become options under (or in addition to) city

# Design Logic:
- Some gestures are so ingrained in the psyches of iPhone users, that I intend to take advantage of this intuitive understanding as much as possible
- The Dashboard will be available from every main screen in the app, once main flow is entered
- The user's first thought about how to do something, or simple discovery through casual use, dictate the fundamental design pattern
- New ideas merit further exploration, but new software packages should be viewed with a skeptical eye

# NEED & HAVE:
- This is the most basic quantum of human interaction, and serves as a starting point
- A need or have may be searched for or created
- When a Need is found that matches search criteria, a user may watch that Need
- When a Have is found that matches search criteria, a user may watch that Have

Known Issues:
- If the project stops recognizing Firebase (including Auth), see: https://github.com/firebase/firebase-ios-sdk/issues/6066#issuecomment-662580211
