(function () {
  var root = document.documentElement;
  var themeToggle = document.getElementById("theme-toggle");
  var toc = document.querySelector(".wiki-toc");
  var wideLayout = window.matchMedia("(min-width: 1280px)");

  function currentTheme() {
    return root.dataset.theme === "dark" ? "dark" : "light";
  }

  function updateThemeControl() {
    if (!themeToggle) return;
    var isDark = currentTheme() === "dark";
    themeToggle.setAttribute("aria-pressed", String(isDark));
    themeToggle.setAttribute("aria-label", isDark ? "切换到浅色模式" : "切换到暗色模式");
  }

  function toggleTheme() {
    var nextTheme = currentTheme() === "dark" ? "light" : "dark";
    root.dataset.theme = nextTheme;
    try { localStorage.setItem("site-theme", nextTheme); } catch (error) {}
    updateThemeControl();
  }

  function syncToc(event) {
    if (!toc) return;
    toc.open = event.matches;
  }

  if (themeToggle) themeToggle.addEventListener("click", toggleTheme);
  if (wideLayout.addEventListener) wideLayout.addEventListener("change", syncToc);

  syncToc(wideLayout);
  updateThemeControl();
})();
