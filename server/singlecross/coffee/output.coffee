
makeLegend = (title,arr,colors) ->
   legendRowTpl = Handlebars.compile($("#legendRowTpl").html())
   legendTpl = Handlebars.compile($("#legendTpl").html())
   
   tbl = {}
   rows = []
   for txt,i in arr
      tbl[txt] = colors[i%colors.length]
      rows.push legendRowTpl({"txt":txt,"color":tbl[txt]})
   legendTpl({"title":title,"rows":rows})

showLegend = (flyMatrix,childGenotype) ->
   gLegends = []
   pLegends = []
   window.foundChild=false
   for row in flyMatrix
      for fly in row
         if childGenotype == fly.genotype
            fly.isChild = true
            window.foundChild=true
         else
            fly.isChild = false
         g = fly.genotype
         idx = gLegends.indexOf g 
         if idx == -1
            fly.gLegendIdx = gLegends.length
            gLegends.push g
         else
            fly.gLegendIdx = idx

         p = fly.phenotype.join " "
         idx = pLegends.indexOf p
         if idx == -1
            fly.pLegendIdx = pLegends.length
            pLegends.push p
         else
            fly.pLegendIdx = idx
   if not window.foundChild && childGenotype !=""
      msg="The cross you have set up does not produce "+childGenotype
      topErrorMsgTpl = Handlebars.compile($("#topErrorMsgTpl").html())
      $("#topErrorMsg").html(topErrorMsgTpl(msg))

   $("#pLegend").html makeLegend("Phenotypes",pLegends,pColors)
   $("#gLegend").html makeLegend("Genotypes",gLegends,gColors)

colorify = (flyMatrix) ->
   window.stickyFlyPanel=""
   flyPanelTpl = Handlebars.compile($("#flyPanelTpl").html())
   clickHighlight = (fly)->
      window.stickyFlyPanel = flyPanelTpl(fly)
      $("#punHoverMsg").html(window.stickyFlyPanel)
      $(".pDiv").removeClass("punCellClickedEqual")
      $(".pDiv").removeClass("punCellClickedUnequal")
      for row,k in flyMatrix
         for cell,l in row
            #$("#fly_"+k+"_"+l).find("div").addClass("punCellClickedUnequal")
            if cell.pLegendIdx==fly.pLegendIdx
               if cell.gLegendIdx==fly.gLegendIdx
                  $("#fly_"+k+"_"+l).find("div").addClass("punCellClickedEqual")
               else
                  $("#fly_"+k+"_"+l).find("div").addClass("punCellClickedUnequal")
   
   $("body").click ->
      $(".pDiv").removeClass("punCellClickedEqual")
      $(".pDiv").removeClass("punCellClickedUnequal")
      $("#punHoverMsg").html("")
   $("#punTable").find("tr").each (i) -> 
      $(this).find("td").each (j) -> 
         if i && j
            fly = flyMatrix[i-1][j-1]
            fly.gColor=gColors[fly.gLegendIdx]
            if fly.lethal
               fly.pColor=lethalColor
            else
               fly.pColor=pColors[fly.pLegendIdx]
            $(this).data({"i":i,"j":j,"fly":fly})
            $(this).attr({"id":"fly_"+(i-1)+"_"+(j-1)})
            $(this).find("div").css("background-color":fly.pColor).find("div").css("background-color":fly.gColor)
            $(this).mouseenter ->
               fly.clashingGenotypes=[]
               for row,k in flyMatrix
                  for cell,l in row
                     if cell.pLegendIdx==fly.pLegendIdx
                        if cell.gLegendIdx==fly.gLegendIdx
                           $("#fly_"+k+"_"+l).find("div").addClass("punCellHoveredEqual")
                        else
                           $("#fly_"+k+"_"+l).find("div").addClass("punCellHoveredUnequal")
                           if cell.genotype not in fly.clashingGenotypes
                              fly.clashingGenotypes.push(cell.genotype)
               $("#punHoverMsg").html flyPanelTpl(fly)

            $(this).mouseleave ->
               $("#punHoverMsg").html(window.stickyFlyPanel)
               $(".pDiv").removeClass("punCellHoveredEqual")
               $(".pDiv").removeClass("punCellHoveredUnequal")
            $(this).click (event)->
               event.stopPropagation()
               clickHighlight(fly)
            if fly.isChild
               clickHighlight(fly)

clickHighlight = (fly)->
   #window.stickyFlyPanel = flyPanelTpl(fly)
   #$("#punHoverMsg").html(window.stickyFlyPanel)
   flyPanelTpl = Handlebars.compile($("#flyPanelTpl").html())
   $("#infoPanel").html(flyPanelTpl(fly))
   $(".pDiv").removeClass("punCellClickedEqual")
   $(".pDiv").removeClass("punCellClickedUnequal")
   for cell in fly.clashes["clashing"]
      $("#fly_"+cell["position"][0]+"_"+cell["position"][1]).find("div").addClass("punCellClickedUnequal")
   for cell in fly.clashes["similar"]
      $("#fly_"+cell["position"][0]+"_"+cell["position"][1]).find("div").addClass("punCellClickedEqual")



addIDsToCells = -> # not being done under similar loop in eventhandler code, because ids of cells after the i,jth cell wont have ids while assigning handlers
   $("#punTable").find("tr").each (i) -> 
      $(this).find("td").each (j) -> 
         if i && j
            $(this).attr({"id":"fly_"+(i-1)+"_"+(j-1)})


addColorAndEventHandlers = ->
   $("body").click ->
      $(".pDiv").removeClass("punCellClickedEqual")
      $(".pDiv").removeClass("punCellClickedUnequal")
      $("#infoPanel").html("")
   $("#punTable").find("tr").each (i) -> 
      $(this).find("td").each (j) -> 
         if i && j
            fly = flyMatrix[i-1][j-1]
            fly.gColor=gColors[fly.gIdx]
            if fly.lethal
               fly.pColor=lethalColor
            else
               fly.pColor=pColors[fly.pIdx]
            #$(this).data({"i":i,"j":j,"fly":fly})
            $(this).find("div").css("background-color":fly.pColor).find("div").css("background-color":fly.gColor)
            $(this).mouseenter ->
               for cell in fly.clashes["clashing"]
                  $("#fly_"+cell["position"][0]+"_"+cell["position"][1]).find("div").addClass("punCellHoveredUnequal")
               for cell in fly.clashes["similar"]
                  $("#fly_"+cell["position"][0]+"_"+cell["position"][1]).find("div").addClass("punCellHoveredEqual")
            $(this).mouseleave ->
               #$("#punHoverMsg").html(window.stickyFlyPanel)
               $(".pDiv").removeClass("punCellHoveredEqual")
               $(".pDiv").removeClass("punCellHoveredUnequal")
            $(this).click (event)->
               event.stopPropagation()
               clickHighlight(fly)
            if fly.isChild
               clickHighlight(fly)
   

findClashingGenotypes = (genotype,phenotype) ->
   similar=[]
   clashing=[]
   for row,k in flyMatrix
      for cell,l in row
         #alert JSON.stringify([flyMatrix[k][l].phenotype.join(" "),phenotype])
         if flyMatrix[k][l].phenotype.join(" ")==phenotype
            if flyMatrix[k][l].genotype==genotype
               similar.push({"position":[k,l]})
            else
               clashing.push({"position":[k,l],"genotype":flyMatrix[k][l].genotype})
   #alert JSON.stringify({"similar":similar,"clashing":clashing})
   return {"similar":similar,"clashing":clashing}

fillFlyMatrix = (punnett,childGenotype) ->
   window.flyMatrix=punnett
   genotypes = []
   phenotypes = []
   window.foundChild=false
   for row in flyMatrix
      for fly in row
         if childGenotype == fly.genotype
            fly.isChild = true
            window.foundChild=true
         else
            fly.isChild = false
         geno = fly.genotype
         idx = genotypes.indexOf geno
         if idx == -1
            fly.gIdx = genotypes.length
            genotypes.push geno
         else
            fly.gIdx = idx

         pheno = fly.phenotype.join(" ")
         idx = phenotypes.indexOf pheno
         if idx == -1
            fly.pIdx = phenotypes.length
            phenotypes.push pheno
         else
            fly.pIdx = idx
         fly.clashes=findClashingGenotypes(geno,pheno)
   if not window.foundChild && childGenotype !=""
      msg="The cross you have set up does not produce "+childGenotype
      topErrorMsgTpl = Handlebars.compile($("#topErrorMsgTpl").html())
      $("#topErrorMsg").html(topErrorMsgTpl(msg))

shortName = (name, limit=20) ->
   if name.length>(limit-3)
      short=name.substr(0,limit-3)+"..."
   else
      short=name
   return short

shortenAxisNames = (axis) ->
   shortAxis=[]
   for name in axis
      shortAxis.push({"name":name,"shortName":shortName(name)})
   return shortAxis
   

window.drawOutputView = (dataFromServer) ->
   $("#backBtnContainer").html "<input type=\'submit\' value=\'Back\' onClick=\'inputMode();return false\'  class=\"btn primary\"/>"
   hdrTpl = Handlebars.compile($("#punHdrTpl").html())
   rowTpl = Handlebars.compile($("#punRowTpl").html())
   punTpl = Handlebars.compile($("#punTpl").html())
   fly1Axis=shortenAxisNames(dataFromServer["fly1Axis"])
   fly2Axis=shortenAxisNames(dataFromServer["fly2Axis"])
   hdrHTML = hdrTpl(fly2Axis)
   rows = []
   for r,i in dataFromServer["punnettSquare"]
      rows.push rowTpl({"gamete":fly1Axis[i],"flies":r})
   punHTML = punTpl({"hdr":hdrHTML,"rows":rows})
   $("#punSqr").html(punHTML)
   fillFlyMatrix(dataFromServer["punnettSquare"],dataFromServer["reformattedChild"])
   addIDsToCells()
   addColorAndEventHandlers()
   #showLegend(dataFromServer["punnettSquare"],dataFromServer["reformattedChild"])
   #colorify(dataFromServer["punnettSquare"])  
   $("#punSqr").scrollTop($("#punSqr").position().top)
   #$(".punTitleCell").mouseenter ->
   #   gametePanelTpl = Handlebars.compile($("#gametePanelTpl").html())
   #   panelHtml=gametePanelTpl($(this).attr("gamete"))
   #   $("#punHoverMsg").html(panelHtml)
   #$(".punTitleCell").mouseleave ->
   #   $("#punHoverMsg").html(window.stickyFlyPanel)
   outputMode()

