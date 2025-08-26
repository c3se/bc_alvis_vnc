// hide the form and launch button
const style = document.createElement("style");
  style.textContent = `
    #new_batch_connect_session_context,
    #new_batch_connect_session_context ~ p {
      display: none !important;
    }
  `;
  document.head.appendChild(style);


// add RDP links based on document title
document.addEventListener("DOMContentLoaded", () => {
  const description_element = document.createElement("links");
  const help_link = "https://www.c3se.chalmers.se/documentation/connecting/remote_graphics";
  const container = document.querySelector("div.ood-appkit.markdown");
  let cluster;
  let links;
  if (document.title.includes("Alvis")) {
      cluster = "Alvis"
      links = ["alvis1.c3se.chalmers.se",
               "alvis2.c3se.chalmers.se"]
   } else {
      cluster = "Vera"
      links = ["vera1.c3se.chalmers.se",
               "vera2.c3se.chalmers.se"]
   }
   let links_content = links.map(link => `<li><a href="https://${link}">https://${link}</a></li>`).join("\n");
   description_element.innerHTML = `
     <div> 
     <p>
     Login nodes on ${cluster} run desktop services in the RDP protocol, you can connect
     to them with different clients (details in our <a href="${help_link}">documentation</a>).
     Or directly through one of the following links:
     <p>
     <ui>
       ${links_content}
     </ui>
     </div>
   `;
    container.appendChild(description_element);
  }
);
