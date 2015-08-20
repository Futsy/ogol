function render() {
  var c = document.getElementById("myCanvas");
  var ctx = c.getContext("2d");
  ctx.beginPath();
  ctx.moveTo(313, 313);
  ctx.lineTo(313, 213);
  ctx.moveTo(313, 213);
  ctx.lineTo(213, 213);
  ctx.moveTo(213, 213);
  ctx.lineTo(213, 313);
  ctx.moveTo(213, 313);
  ctx.lineTo(313, 313);
  ctx.moveTo(250, 250);
  ctx.lineTo(350, 250);
  ctx.moveTo(350, 250);
  ctx.lineTo(350, 390);
  ctx.moveTo(350, 390);
  ctx.lineTo(250, 390);
  ctx.moveTo(250, 390);
  ctx.lineTo(250, 250);
  ctx.stroke();
}