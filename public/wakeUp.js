window.addEventListener("focus", () => {
    redirect()
});
document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("submit").addEventListener("click", () => {
       redirect()
    })
});

function redirect() {
    let path = sessionStorage.getItem("previousPath")
    let href= window.location.origin + path;
    window.location.replace(href);
}

