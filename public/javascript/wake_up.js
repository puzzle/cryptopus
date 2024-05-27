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
    if (path) {
        window.location.replace(window.location.origin + path);
    }else{
        window.location.replace(window.location.origin);
    }
}

