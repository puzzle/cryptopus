window.addEventListener("focus", () => {
    let path = sessionStorage.getItem("previousPath")
    window.location.replace(path);
});