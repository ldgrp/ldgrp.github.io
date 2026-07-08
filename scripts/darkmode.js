// From https://flowbite.com/docs/customize/dark-mode/
var themeToggleDarkIcon = document.getElementById("theme-toggle-dark-icon");
var themeToggleLightIcon = document.getElementById("theme-toggle-light-icon");

var prefersDark = window.matchMedia("(prefers-color-scheme: dark)");

function isDark() {
  var stored = localStorage.getItem("color-theme");
  if (stored === "dark") return true;
  if (stored === "light") return false;
  return prefersDark.matches;
}

function updateIcons() {
  var dark = isDark();
  themeToggleLightIcon.classList.toggle("hidden", !dark);
  themeToggleDarkIcon.classList.toggle("hidden", dark);
}

updateIcons();

prefersDark.addEventListener("change", function () {
  if (!localStorage.getItem("color-theme")) updateIcons();
});

document
  .getElementById("theme-toggle")
  .addEventListener("click", function () {
    var root = document.documentElement;
    if (isDark()) {
      root.classList.remove("dark");
      root.classList.add("light");
      localStorage.setItem("color-theme", "light");
    } else {
      root.classList.remove("light");
      root.classList.add("dark");
      localStorage.setItem("color-theme", "dark");
    }
    updateIcons();
  });
