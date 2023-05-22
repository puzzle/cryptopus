window.addEventListener("focus", () => {
    redirect()
});
document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("submit").addEventListener("click", () => {
       redirect()
    })
});

function redirect() {
    const path = sessionStorage.getItem("previousPath")
    sessionStorage.removeItem("previousPath")
    const href= window.location.origin + path;
    window.location.replace(href);
}

