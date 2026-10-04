# Priyadarsini & Sathiskumar — wedding invitation

A self-contained, mobile-first wedding invitation. Open index.html in a browser or publish this folder as a static website. It has no build step or third-party JavaScript dependencies.

## Personalize the invitation

Edit wedding-details.js to update names, event date, event time, venue, map links, or the music file. When the date changes, update dateISO, startISO, and endISO together. The written invitation and photo captions live in index.html; edit that file to change any on-page copy. Replace a JPEG in assets/ to change its photograph while keeping the same filename.

The supplied soundtrack in assets/wedding-music.mp3 starts when a guest taps Open invitation; the music note in the header pauses or resumes it. Browsers on phones require that tap before they will play sound. To replace the track, use the same filename and keep musicEnabled set to true in wedding-details.js.

## Sharing preview

For a rich WhatsApp preview, publish the folder to a public HTTPS URL and set absolute URLs in og:image, twitter:image, and og:url in index.html. Use the public URL for the image, for example https://your-domain.example/assets/main-couple.jpg; social preview bots need a publicly reachable image. Update the page title and description in the same file if you personalize the invitation.

## Included interactions

- Animated invitation cover
- Scratch-to-reveal date with a tap-accessible alternative and falling petals
- Live countdown to the ceremony
- Tap-to-expand photo gallery
- Venue map and directions
- Share sheet, music control, and calendar download
- Reduced-motion and small-screen support
