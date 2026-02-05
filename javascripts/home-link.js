// Make site title clickable to go home
document.addEventListener('DOMContentLoaded', function() {
  const siteTitle = document.querySelector('.md-header__title');
  if (siteTitle) {
    siteTitle.style.cursor = 'pointer';
    siteTitle.addEventListener('click', function() {
      window.location.href = '/home/';
    });
  }
});
