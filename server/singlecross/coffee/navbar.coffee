
navbarHtml="""    <div class="topbar" data-scrollspy="scrollspy"> 
      <div class="topbar-inner"> 
        <div class="container"> 
          <a class="brand" href="index.html">flyCrosser</a> 
          <ul class="nav"> 
            <li id=navHelp><a href="help.html">Help</a></li> 
            <li id=navAbout><a href="about.html">About</a></li> 
          </ul> 
        </div> 
      </div>
    </div>"""

$ ->
   $("#navbar").html(navbarHtml)
