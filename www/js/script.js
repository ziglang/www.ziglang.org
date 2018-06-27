window.onscroll = function() {fixNavbar()};

var navbar = document.getElementById("navbar");
var sticky = navbar.offsetTop;

function fixNavbar() {
  if (window.pageYOffset >= sticky) {
    navbar.classList.add("sticky");
  } else {
    navbar.classList.remove("sticky");
  }
} 

