'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "c1f093d09ba7b48f0e2576adf815db55",
"version.json": "1951ca8c24da83de3b0d8f8153c20c4d",
"index.html": "17a813d8ebfc6a2af89d0ffb86d87782",
"/": "17a813d8ebfc6a2af89d0ffb86d87782",
"main.dart.js": "e44dca4303226d35e10da54fb816089d",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "6bed17ea99fd33772856ac2418ba5ff8",
"assets/AssetManifest.json": "cd9df34a9ffa3dccfba639139baace5d",
"assets/NOTICES": "57ec5d3bc20e813a4c050840748a2546",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "07fdba684df6a01ef0b400fae0ed6501",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "c8a684c3db5478e3c4f68e8d205fca7f",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "2d0c7617da73010c910dfaf30f325ef9",
"assets/fonts/MaterialIcons-Regular.otf": "1f0530aa1204a71273ad3f8f7a278393",
"assets/assets/svg/ic_repair.png": "1689ff6aa878642fb9f437d93c5191a7",
"assets/assets/svg/ic_plus.svg": "3e02a9cf5bcf128e33ce9d1d72288409",
"assets/assets/svg/task_2.svg": "4e6090e5d4a26fa23a575d199e314ce4",
"assets/assets/svg/ic_return_right.svg": "bd374ad88cbf50a6d32e2f8c5c58b672",
"assets/assets/svg/ic_mb_path.png": "b1d4cdeed8cfa4179ab573477c086bcd",
"assets/assets/svg/ic_end.svg": "a2c12b1f33acbd81a907afd5f1ce41ac",
"assets/assets/svg/task_1.svg": "b29a49bbada002e60c4ec0f45ee84a07",
"assets/assets/svg/ic_file_code.png": "e431649d556277ce1e62dfee03c90b93",
"assets/assets/svg/ic_return.svg": "bd374ad88cbf50a6d32e2f8c5c58b672",
"assets/assets/svg/ic_timeout.svg": "aabf36db101863e82d62114b19a947f9",
"assets/assets/svg/ic_ze_checked.png": "da8ba24c1900cc6a141e161dfbe28a06",
"assets/assets/svg/ic_system.png": "369693fd45ec119aa7debb774bf8d420",
"assets/assets/svg/ic_editor.png": "45cb64ce0ca53b87e5d1f81bca87f91e",
"assets/assets/svg/ic_mb_ellipsis_filled.png": "f840ddfcb9a8ef73205f875ef1f0cfb3",
"assets/assets/svg/ic_md_save.svg": "8becfa2346486bd642b3f99710831116",
"assets/assets/svg/ic_ze-bars.png": "0f3e9ee04aedfe857633d6a019397700",
"assets/assets/svg/ic_trigger.svg": "d35c25cfe1e9bd19385983f250e7e944",
"assets/assets/svg/ic_delay.svg": "4c11f1c0d0d6c9561d587c70486ccdaa",
"assets/assets/svg/ic_grab.svg": "2c412cac306ad5ae2c43fa104987bb81",
"assets/assets/svg/ic_more.svg": "d58ffa977727d3920e1f66fafcb51a57",
"assets/assets/images/ic_plus.png": "6093c6cbf11f63de8c46e329c69891f6",
"assets/assets/images/ic_task_2.png": "b5fff63763f6630e86ee10315b90ec4f",
"assets/assets/images/ic_task_1.png": "61b0c472ecdb389d05526bb078002d49",
"assets/assets/json/FlowChart.json": "45f2bdd8557e403dd05110295ede4f53",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
