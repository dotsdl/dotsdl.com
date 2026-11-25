/* Time-of-day glow: retints the top-of-page glow by the reader's local hour.
   Night teal -> dawn rose -> day mint -> dusk gold -> night. Preview any hour with ?hour=19. */
(function () {
  var stops = [ /* hour, r, g, b, strength */
    [0, 70, 132, 150, 0.6], [5, 70, 132, 150, 0.6], [7, 236, 166, 128, 0.9],
    [9.5, 126, 226, 184, 1], [16, 126, 226, 184, 1], [18.5, 224, 172, 82, 1.15],
    [20.5, 70, 132, 150, 0.6], [24, 70, 132, 150, 0.6]
  ];
  function tint() {
    var q = new URLSearchParams(location.search).get("hour"), d = new Date();
    var h = (q !== null && q !== "" && !isNaN(q)) ? ((+q % 24) + 24) % 24 : d.getHours() + d.getMinutes() / 60;
    var i = 1;
    while (i < stops.length - 1 && stops[i][0] < h) i++;
    var a = stops[i - 1], b = stops[i], t = (h - a[0]) / (b[0] - a[0]), v = [];
    for (var j = 1; j < 5; j++) v.push(a[j] + (b[j] - a[j]) * t);
    var s = document.documentElement.style;
    s.setProperty("--glow-rgb", Math.round(v[0]) + ", " + Math.round(v[1]) + ", " + Math.round(v[2]));
    s.setProperty("--glow-k", v[3].toFixed(2));
  }
  tint();
  setInterval(tint, 300000);
})();
