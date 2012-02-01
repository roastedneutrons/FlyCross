
navbarHtml="""    <div class="topbar" data-scrollspy="scrollspy"> 
      <div class="topbar-inner"> 
        <div class="container"> 
          <a class="brand" href="/">flyUtils</a> 
          <ul class="nav"> 
            <li id=navSinglecross><a href="index.html">singleCross</a></li> 
            <li id=navHelp><a href="help.html">Help</a></li> 
            <li id=navAbout><a href="about.html">About</a></li>
            <li id=navFeedback><a href="feedback.html">Feedback</a></li>
          </ul> 
        </div> 
      </div>
    </div>"""

$ ->
   $("#navbar").html(navbarHtml)
