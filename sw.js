/* Service worker for the Interview Prep PWA.
   Goal: make the app installable ("Add to Home Screen") and work offline, while
   ALWAYS serving the latest code so deploys land immediately (no "one visit
   behind"). Live question data always comes fresh from Supabase over the network.

   Strategy:
   - HTML / CSS / JS (app code): network-first — always try the network so the
     newest code loads; fall back to cache only when offline.
   - Icons / manifest (rarely change): cache-first for speed.
   - Cross-origin (Supabase, fonts, Font Awesome CDN): not intercepted. */

const CACHE = "fsprep-v2";
const SHELL = [
  "./",
  "./index.html",
  "./style.css",
  "./script.js",
  "./manifest.webmanifest",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/apple-touch-icon.png",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll(SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.map((k) => (k === CACHE ? null : caches.delete(k)))))
      .then(() => self.clients.claim())
  );
});

function networkFirst(req, fallbackKey) {
  return fetch(req)
    .then((res) => {
      if (res && res.status === 200) {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(fallbackKey || req, copy));
      }
      return res;
    })
    .catch(() => caches.match(fallbackKey || req).then((c) => c || caches.match("./index.html")));
}

function cacheFirst(req) {
  return caches.match(req).then((cached) => cached || fetch(req).then((res) => {
    if (res && res.status === 200) {
      const copy = res.clone();
      caches.open(CACHE).then((c) => c.put(req, copy));
    }
    return res;
  }));
}

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return; // Supabase / fonts / CDN → network

  // Page navigations → network-first, fall back to the cached shell offline.
  if (req.mode === "navigate") {
    event.respondWith(networkFirst(req, "./index.html"));
    return;
  }

  // App code (CSS/JS) → network-first so new deploys always load.
  if (/\.(?:js|css)(?:\?|$)/.test(url.pathname)) {
    event.respondWith(networkFirst(req));
    return;
  }

  // Everything else same-origin (icons, manifest) → cache-first for speed.
  event.respondWith(cacheFirst(req));
});
