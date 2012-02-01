
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


window.showPunnett = (pun) ->
   $("#backBtnContainer").html "<input type=\'submit\' value=\'Back\' onClick=\'inputMode();return false\'  class=\"btn primary\"/>"
   hdrTpl = Handlebars.compile($("#punHdrTpl").html())
   rowTpl = Handlebars.compile($("#punRowTpl").html())
   punTpl = Handlebars.compile($("#punTpl").html())
   hdrHTML = hdrTpl(pun)
   rows = []
   for r,i in pun["punnettSquare"]
      rows.push rowTpl({"gamete":pun["fly1Axis"][i],"flies":r})
   punHTML = punTpl({"hdr":hdrHTML,"rows":rows})
   $("#punSqr").html(punHTML)
   showLegend(pun["punnettSquare"],pun["reformattedChild"])
   colorify(pun["punnettSquare"])  
   $("#punSqr").scrollTop($("#punSqr").position().top)
   $(".punTitleCell").mouseenter ->
      gametePanelTpl = Handlebars.compile($("#gametePanelTpl").html())
      panelHtml=gametePanelTpl($(this).attr("gamete"))
      $("#punHoverMsg").html(panelHtml)
   $(".punTitleCell").mouseleave ->
      $("#punHoverMsg").html(window.stickyFlyPanel)
   outputMode()

