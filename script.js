(function () {
  "use strict";
  var details = window.WEDDING_DETAILS;
  var cover = document.getElementById("opening-cover");
  var openingButton = document.getElementById("open-invitation");
  var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var toast = document.getElementById("toast");
  var toastTimer;

  function coupleNames() { return details.bride + " & " + details.groom; }
  function longDate() {
    var parsed = new Date(details.dateISO + "T12:00:00");
    return new Intl.DateTimeFormat("en", { weekday: "long", day: "numeric", month: "long", year: "numeric" }).format(parsed);
  }
  function shortDate() {
    var bits = details.dateISO.split("-");
    return bits[2] + " · " + bits[1] + " · " + bits[0];
  }
  function setText(selector, value) {
    document.querySelectorAll(selector).forEach(function (node) { node.textContent = value; });
  }
  function applyDetails() {
    setText("[data-bride]", details.bride);
    setText("[data-groom]", details.groom);
    setText("[data-couple-names]", coupleNames());
    setText("[data-date-short]", shortDate());
    setText("[data-date-long]", longDate());
    setText("[data-date-reveal]", new Intl.DateTimeFormat("en", { day: "numeric", month: "long", year: "numeric" }).format(new Date(details.dateISO + "T12:00:00")));
    setText("[data-time]", details.time);
    setText("[data-venue]", details.venue);
    document.title = details.bride + " & " + details.groom + " — A Wedding Invitation";
    document.getElementById("directions-link").href = details.mapsLink;
    document.getElementById("venue-map").src = details.mapEmbed;
    var schema = document.getElementById("event-schema");
    schema.textContent = JSON.stringify({
      "@context": "https://schema.org", "@type": "Event", name: "The wedding of " + coupleNames(),
      startDate: details.startISO, endDate: details.endISO, eventAttendanceMode: "https://schema.org/OfflineEventAttendanceMode",
      location: { "@type": "Place", name: details.venue, sameAs: details.mapsLink }
    });
  }
  applyDetails();

  function showToast(message) {
    toast.textContent = message;
    toast.classList.add("is-visible");
    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(function () { toast.classList.remove("is-visible"); }, 3600);
  }

  openingButton.addEventListener("click", function () {
    openingButton.disabled = true;
    cover.classList.add("is-opening");
    document.body.classList.remove("invite-closed");
    var invitationContent = document.getElementById("invitation-content");
    invitationContent.removeAttribute("inert");
    invitationContent.setAttribute("aria-hidden", "false");
    startWeddingMusic();
    window.setTimeout(function () {
      cover.hidden = true;
      cover.setAttribute("aria-hidden", "true");
      document.getElementById("home").focus({ preventScroll: true });
    }, reducedMotion ? 20 : 1300);
  });

  var revealElements = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window && !reducedMotion) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -30px 0px" });
    revealElements.forEach(function (element) { observer.observe(element); });
  } else {
    revealElements.forEach(function (element) { element.classList.add("is-visible"); });
  }

  var countdownTarget = new Date(details.startISO).getTime();
  var countdownIds = ["count-days", "count-hours", "count-minutes", "count-seconds"];
  var countdownMessage = document.getElementById("countdown-message");
  function updateCountdown() {
    var remaining = countdownTarget - Date.now();
    if (remaining <= 0) {
      countdownIds.forEach(function (id) { document.getElementById(id).textContent = "00"; });
      countdownMessage.textContent = "Our celebration day is here. See you soon!";
      return;
    }
    var days = Math.floor(remaining / 86400000);
    var hours = Math.floor((remaining % 86400000) / 3600000);
    var minutes = Math.floor((remaining % 3600000) / 60000);
    var seconds = Math.floor((remaining % 60000) / 1000);
    [days, hours, minutes, seconds].forEach(function (value, index) {
      document.getElementById(countdownIds[index]).textContent = String(value).padStart(2, "0");
    });
    countdownMessage.textContent = "Until we celebrate together";
  }
  updateCountdown();
  window.setInterval(updateCountdown, 1000);

  var canvas = document.getElementById("scratch-layer");
  var ctx = canvas.getContext("2d", { willReadFrequently: true });
  var scratchCard = document.getElementById("date-card");
  var scratching = false;
  var scratchCleared = false;
  function drawScratchSurface() {
    var rect = scratchCard.getBoundingClientRect();
    var dpr = Math.min(window.devicePixelRatio || 1, 2);
    if (!rect.width || !rect.height) return;
    ctx.globalCompositeOperation = "source-over";
    canvas.width = Math.round(rect.width * dpr);
    canvas.height = Math.round(rect.height * dpr);
    canvas.style.width = rect.width + "px";
    canvas.style.height = rect.height + "px";
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    var gradient = ctx.createLinearGradient(0, 0, rect.width, rect.height);
    gradient.addColorStop(0, "#d7c194");
    gradient.addColorStop(.48, "#b99862");
    gradient.addColorStop(1, "#ddcba8");
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, rect.width, rect.height);
    ctx.strokeStyle = "rgba(255,248,230,.3)";
    ctx.lineWidth = 1;
    for (var x = -rect.height; x < rect.width; x += 17) {
      ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x + rect.height, rect.height); ctx.stroke();
    }
    ctx.strokeStyle = "rgba(94,64,37,.24)";
    ctx.beginPath(); ctx.rect(17, 17, rect.width - 34, rect.height - 34); ctx.stroke();
    ctx.fillStyle = "#fff8e7";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.font = "21px Georgia, serif";
    ctx.fillText("✿", rect.width / 2, rect.height / 2 - 37);
    ctx.font = "italic 23px Georgia, serif";
    ctx.fillText("A date to remember", rect.width / 2, rect.height / 2 - 3);
    ctx.font = "10px Segoe UI, sans-serif";
    ctx.fillStyle = "rgba(255,248,230,.86)";
    ctx.fillText("SCRATCH TO REVEAL", rect.width / 2, rect.height / 2 + 34);
  }
  function scratchAt(event) {
    var rect = canvas.getBoundingClientRect();
    ctx.globalCompositeOperation = "destination-out";
    ctx.beginPath();
    ctx.arc(event.clientX - rect.left, event.clientY - rect.top, 23, 0, Math.PI * 2);
    ctx.fill();
  }
  function scratchPercent() {
    var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
    var erased = 0;
    var total = 0;
    for (var i = 3; i < imageData.length; i += 4 * 16) {
      total++;
      if (imageData[i] < 80) erased++;
    }
    return total ? erased / total : 0;
  }
  function releaseScratch() {
    if (!scratching) return;
    scratching = false;
    if (scratchPercent() > .39) revealDate();
  }
  function burstPetals() {
    var burst = document.getElementById("petal-burst");
    for (var i = 0; i < 26; i++) {
      var petal = document.createElement("span");
      var angle = Math.random() * Math.PI * 2;
      var distance = 95 + Math.random() * Math.min(window.innerWidth * .55, 300);
      petal.className = "petal";
      petal.style.setProperty("--petal-x", Math.cos(angle) * distance + "px");
      petal.style.setProperty("--petal-y", Math.sin(angle) * distance + "px");
      petal.style.setProperty("--petal-r", Math.round(Math.random() * 800 - 400) + "deg");
      petal.style.animationDelay = (Math.random() * .18) + "s";
      burst.appendChild(petal);
      window.setTimeout(function (node) { node.remove(); }, 2400, petal);
    }
  }
  function revealDate() {
    if (scratchCleared) return;
    scratchCleared = true;
    canvas.classList.add("is-cleared");
    document.getElementById("scratch-hint").textContent = "14 November 2026 · See you there ✦";
    burstPetals();
  }
  drawScratchSurface();
  if ("ResizeObserver" in window) {
    new ResizeObserver(function () { if (!scratchCleared) drawScratchSurface(); }).observe(scratchCard);
  } else {
    window.addEventListener("resize", function () { if (!scratchCleared) drawScratchSurface(); });
  }
  canvas.addEventListener("pointerdown", function (event) {
    if (scratchCleared) return;
    scratching = true;
    canvas.setPointerCapture(event.pointerId);
    scratchAt(event);
  });
  canvas.addEventListener("pointermove", function (event) { if (scratching) scratchAt(event); });
  canvas.addEventListener("pointerup", releaseScratch);
  canvas.addEventListener("pointercancel", releaseScratch);
  document.getElementById("reveal-date").addEventListener("click", revealDate);

  var audio = document.getElementById("wedding-audio");
  var musicButton = document.getElementById("music-toggle");
  audio.src = details.musicFile;
  function setMusicState(isPlaying) {
    musicButton.classList.toggle("is-playing", isPlaying);
    musicButton.setAttribute("aria-pressed", String(isPlaying));
    musicButton.setAttribute("aria-label", isPlaying ? "Pause wedding music" : "Play wedding music");
  }
  function startWeddingMusic() {
    if (!details.musicEnabled || !details.musicFile) {
      showToast("Wedding music was not attached. Add a song at " + details.musicFile + " and enable it in wedding-details.js.");
      return;
    }
    audio.play().then(function () {
      setMusicState(true);
    }).catch(function () {
      setMusicState(false);
      showToast("Tap the music note to start the wedding music.");
    });
  }
  musicButton.addEventListener("click", function () {
    if (audio.paused) startWeddingMusic();
    else audio.pause();
  });
  audio.addEventListener("pause", function () { setMusicState(false); });

  var lightbox = document.getElementById("lightbox");
  var lightboxImage = document.getElementById("lightbox-image");
  document.querySelectorAll(".gallery-item").forEach(function (item) {
    item.addEventListener("click", function () {
      lightboxImage.src = item.dataset.image;
      lightboxImage.alt = item.dataset.alt;
      lightbox.showModal();
    });
  });
  document.getElementById("lightbox-close").addEventListener("click", function () { lightbox.close(); });
  lightbox.addEventListener("click", function (event) { if (event.target === lightbox) lightbox.close(); });

  document.getElementById("share-invitation").addEventListener("click", async function () {
    var shareData = { title: document.title, text: "Join us for the wedding of " + coupleNames() + " on " + longDate() + " at " + details.venue + ".", url: window.location.href };
    try {
      if (navigator.share) await navigator.share(shareData);
      else if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(window.location.href);
        showToast("Invitation link copied. Send it to your loved ones.");
      } else {
        window.prompt("Copy your invitation link", window.location.href);
      }
    } catch (error) { if (error.name !== "AbortError") showToast("Share this page using your browser's share menu."); }
  });

  document.getElementById("calendar-invitation").addEventListener("click", function () {
    function icsDate(value) { return new Date(value).toISOString().replace(/[-:]/g, "").replace(/\.\d{3}/, ""); }
    function escapeICS(value) { return value.replace(/\\/g, "\\\\").replace(/;/g, "\\;").replace(/,/g, "\\,").replace(/\n/g, "\\n"); }
    var title = "The wedding of " + coupleNames();
    var location = details.venue;
    var event = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//Priyadarsini and Sathiskumar//Wedding invitation//EN", "BEGIN:VEVENT", "UID:" + Date.now() + "@wedding-invitation", "DTSTAMP:" + icsDate(new Date().toISOString()), "DTSTART:" + icsDate(details.startISO), "DTEND:" + icsDate(details.endISO), "SUMMARY:" + escapeICS(title), "LOCATION:" + escapeICS(location), "URL:" + details.mapsLink, "END:VEVENT", "END:VCALENDAR"].join("\r\n");
    var blob = new Blob([event], { type: "text/calendar;charset=utf-8" });
    var link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = "Priyadarsini-and-Sathiskumar-wedding.ics";
    link.click();
    URL.revokeObjectURL(link.href);
  });
})();
