{{flutter_js}}
{{flutter_build_config}}

(async function () {
  if (window.assetTrackerCacheCleanup) {
    await window.assetTrackerCacheCleanup;
  }

  if ('serviceWorker' in navigator) {
    const registrations = await navigator.serviceWorker.getRegistrations();
    await Promise.all(registrations.map((registration) => registration.unregister()));
  }

  await _flutter.loader.load();
})();
