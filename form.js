console.log("=== BEGIN VNC form.js ===")
t0 = performance.now()

/*
NOTE 2024-03-21 arvid:
You could have a try catch here if the ID of the form would be likely to
change. If not you'll most likely get a

    > Uncaught TypeError: document.getElementById(...) is null

if it has. 
*/
launch = document
    .getElementById("new_batch_connect_session_context")
    .querySelector('input[value="Launch"]')

launch.disabled = true

;(async () => {
    console.log("retrieving active jobs..")
    try {
        const res = await fetch("/pun/sys/dashboard/activejobs.json?jobcluster=all&jobfilter=user");
        const json = await res.json()

        console.log(`got response status: ${res.status}`)
        /*
        NOTE 2024-03-21 arvid:
        Attempts to find an already running vnc session. The LinuxHost adapter
        exposes somewhat limited fields. That may change, if the "jobname" field
        could be set the filtering could be refactored to something much nicer and
        robust.
        */
        active_session = json.data.flat().some(e =>
            e.pbsid.toLowerCase().startsWith("launched-by-ondemand-")
            && e.queue.toLowerCase().startsWith("linuxhost")
            && e.status.toLowerCase() === "running"
        )
        console.log(`found active session: ${active_session}`)

        launch.disabled = active_session ? true : false
    } catch (err) {
        console.error("..couldn't retrieve active jobs")
        console.error(err)

        /* 
        NOTE 2024-03-21 arvid: 
        If the retrieval or parsing of the active jobs data goes wrong the
        default behavior can be either to fallback permissively or not.
        */
        launch.disabled = false
    } finally {
        console.log(`=== END VNC form.js (${performance.now() - t0}ms) ===`);
    }
})()
