let progressInterval = null;
let resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'vorp_progressbar';

window.addEventListener('message', (event) => {
    const data = event.data;
    switch (data.type) {
        case 'vp-open': 
            startProgress(data.message, data.mili);
            break;
        case 'vp-cancel':
            stopProgress(false);
            break;
    }
});

function startProgress(text, duration) {
    // DÜZELTME: JS'nin HTML elementlerini bulacağından emin olalım
    const container = document.getElementById('progressContainer');
    const progressText = document.getElementById('progressText');
    const progressFill = document.getElementById('progressBarFill');

    console.log(text);

    progressText.textContent = text;
    progressFill.style.width = '0%';

    container.classList.remove('fadeOut');
    container.classList.add('active');

    let startTime = Date.now();
    const updateInterval = 50; 

    if (progressInterval) clearInterval(progressInterval);

    progressInterval = setInterval(() => {
        const elapsed = Date.now() - startTime;
        const progress = Math.min((elapsed / duration) * 100, 100);
        progressFill.style.width = progress + '%';

        if (progress >= 100) {
            clearInterval(progressInterval);
            progressInterval = null; 
            stopProgress(true);
        }
    }, updateInterval);
}

function stopProgress(finished) {
    const container = document.getElementById('progressContainer');
    if (!container.classList.contains('active')) return;
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }

    if (finished) {
        fetch(`https://${resourceName}/ProgressFinished`, {
            method: "POST",
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        });
    }

    container.classList.add('fadeOut');
    container.classList.remove('active');

    setTimeout(() => {
         container.classList.remove('fadeOut');
    }, 350);
}
