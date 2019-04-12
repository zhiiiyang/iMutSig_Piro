server <- function(input, output) {
  addClass(selector = "body", class = "sidebar-collapse")
  
  
  output$menu <- renderMenu({
    sidebarMenu(
      menuItem(paste("All data were most recently updated on:",as.Date(file.info("data/COSMIC.rdata")$mtime)), 
               icon = icon("calendar"))
    )
  })
  
  
  observeEvent(input$mysidebar, {
    # for desktop browsers
    addClass(selector = "body", class = "sidebar-collapse")
    # for mobile browsers
    removeClass(selector = "body", class = "sidebar-open")
  })
  
  ########
  # Page 1
  ########
  index <- reactive({
    as.numeric(stringr::str_extract(input$N_F,"\\d+"))
  })
  
  indexS <- reactive({
    as.numeric(stringr::str_extract(input$N_S_D,"\\d+"))
  })
  
  
  output$mytable1 <- renderDataTable({
    table <- cbind(
      `COSMIC` = paste0("C", index()),
      `pmsignature` = paste0("P", 1:dim(corr_mat)[1]),
      `Similarity` = round(corr_mat[, index()], 3)
    )
    table <- table[order(table[, 3], decreasing = TRUE), ]
    rownames(table) <- NULL
    datatable(table, options = list(
      pageLength = 3, searching = FALSE,
      pagingType = "simple", lengthChange = FALSE
    )) %>%
      formatStyle(columns = 1:3, "text-align" = "center")
  })
  
  
  #Selected signature
  
  output$corrplot1_1 <- renderPlot({
    corrplot(t(corr_mat)[index(), , drop = FALSE],
             is.corr = FALSE,
             tl.col = "black", method = "shade", col = col(200),
             p.mat = t(corr_mat)[index(), , drop = FALSE] %>% round(1),
             insig = "p-value", tl.srt = 0, tl.offset = 1,
             tl.cex = 1.2, cl.pos = "n"
    )
  })
  
  output$corrplot1_2 <- renderPlot({
    corrplot(cosmic_corr[index(), , drop = FALSE],
             is.corr = FALSE, bg = "#F8F8FF",
             col = myCol(200), tl.col = "black",
             tl.cex = 0.9, cl.pos = "n", cl.lim = c(0, 1)
    )
  })
  
  #Selected signature
  
  output$selected_sig_1 <- renderPlot({
    visPMS_full_modified(sig_full[, index() + 3], 3, FALSE)
  })
  
  # Page 1: selected signature
  output$selected_sig_full_1 <- renderPlot({
    visPMS_full_modified(sig_full[, index() + 3], 3, FALSE)
  })
  
  output$selected_sig_text_1 <- renderText({
    HTML(paste0(
      "<b>Type:</b> COSMIC signature C", index(), "</br>",
      "<b>", "Cancer Membership:</b> ", paste(names(which(cosmic_corr[index(), ] == 1)), collapse = ", ")
    ))
  })
  
  # the most similar signature
  output$selected_sig_full_1_1 <- renderPlot({
    rank <- as.numeric(gsub("[^0-9.]", "", names(sort(t(corr_mat)[index(), ], decreasing = TRUE)[1:1])))
    pmsignature:::visPMS_ind(Fs[[rank]], 5, isScale = TRUE)
  })
  
  output$selected_sig_pm_full_1_1 <- renderPlot({
    rank <- as.numeric(gsub("[^0-9.]", "", names(sort(t(corr_mat)[index(), ], decreasing = TRUE)[1:1])))
    visPMS_full_modified(convertSignatureMatrixToVector(Fs[[rank]], c(6, 4, 4)), 3, FALSE)
  })
  
  output$selected_sig_text_1_1 <- renderText({
    rank <- as.numeric(gsub("[^0-9.]", "", names(sort(t(corr_mat)[index(), ], decreasing = TRUE)[1:1])))
    HTML(paste(
      "<b>Type:</b> pmsignature ", paste0("P", rank), "</br>",
      "<b>Similarity(highest):</b> ", t(corr_mat)[index(), rank] %>% round(3), "</br>", "</b>",
      "<b>", "Cancer Membership:", "</b>",
      paste(names(which(pm_corr[rank, ] == 1)), collapse = ", ")
    ))
  })
  
  # self-defined signature
  output$selected1_1 <- renderValueBox({
    valueBox(
      paste0("C", index()), "COSMIC signature",
      icon = icon("list"),
      color = "blue"
    )
  })
  
  output$highest <- renderValueBox({
    rank <- as.numeric(gsub("[^0-9.]", "", names(sort(t(corr_mat)[index(), ], decreasing = TRUE)[1:1])))
    valueBox(
      paste0("P", rank), "Most similar pmsignature", icon("thumbs-up", lib = "glyphicon"),
      color = "green"
    )
  })
  
  
  output$selected1_2 <- renderValueBox({
    valueBox(
      paste0("P", indexS()), "pmsignature input",
      icon = icon("user"),
      color = "yellow"
    )
  })
  
  output$selected_sig_full_1_2 <- renderPlot({
    pmsignature:::visPMS_ind(Fs[[indexS()]], 5, isScale = TRUE)
  })
  
  output$selected_sig_pm_full_1_2 <- renderPlot({
    visPMS_full_modified(convertSignatureMatrixToVector(Fs[[indexS()]], c(6, 4, 4)), 3, FALSE)
  })
  
  output$selected_sig_text_1_2 <- renderText({
    HTML(paste(
      "<b>Type:</b> pmsignature ", paste0("P", indexS()), "</br>",
      "<b>Similarity(selected):</b> ", t(corr_mat)[index(), indexS()] %>% round(3), "</br>", "</b>",
      "<b>", "Cancer Membership:", "</b>",
      paste(names(which(pm_corr[indexS(), ] == 1)), collapse = ", ")
    ))
  })
  
  
  ########
  # Page 2
  ########

  index2 <- reactive({
    as.numeric(stringr::str_extract(input$N_D,"\\d+"))
  })
  
  indexS2 <- reactive({
    as.numeric(stringr::str_extract(input$N_D_S,"\\d+"))
  })
  
  rank1 <- reactive({
    as.numeric(gsub("[^0-9.]", "", names(sort(corr_mat[index2(), ], decreasing = TRUE)[1:1])))
  })


  output$mytable2 <- renderDataTable({
    table <- cbind(
      `pmsignature` = paste0("P", index2()),
      `COSMIC Signature` = paste0("C", 1:dim(corr_mat)[2]),
      `Similarity` = round(corr_mat[index2(), ], 3)
    )
    rownames(table) <- NULL
    table <- table[order(table[, 3], decreasing = TRUE), ]
    datatable(table, options = list(
      pageLength = 3, searching = FALSE,
      pagingType = "simple", lengthChange = FALSE
    )) %>%
      formatStyle(columns = 1:3, "text-align" = "center")
  })

  # Page 1: first two rows
  col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))

  output$corrplot2_1 <- renderPlot({
    corrplot(pm_corr[index2(), , drop = FALSE],
      is.corr = FALSE, bg = "#F8F8FF",
      col = myCol(200), tl.col = "black",
      tl.cex = 1.2, cl.pos = "n"
    )
  })

  output$corrplot2_2 <- renderPlot({
    corrplot(corr_mat[index2(), , drop = FALSE],
      is.corr = FALSE,
      tl.col = "black", method = "shade", col = col(200),
      p.mat = corr_mat[index2(), , drop = FALSE] %>% round(1),
      insig = "p-value", tl.srt = 0, tl.offset = 1,
      tl.cex = 1.2, cl.pos = "n"
    )
  })



  output$selected_sig_2 <- renderPlot({
    pmsignature:::visPMS_ind(Fs[[index2()]], 5, isScale = TRUE)
  })

  output$selected_sig_2_1 <- renderPlot({
    pmsignature:::visPMS_ind(Fs[[index2()]], 5, isScale = TRUE)
  })
  
  # Page 1: selected signature

  output$selected_sig_full_2 <- renderPlot({
    visPMS_full_modified(convertSignatureMatrixToVector(Fs[[index2()]], c(6, 4, 4)), 3, FALSE)
  })

  output$selected_sig_text_2 <- renderText({
    HTML(paste0(
      "<b>Type:</b> pmsignature P", index2(), "</br>",
      "<b>", "Cancer Membership:</b> ", paste(names(which(pm_corr[index2(), ] == 1)), collapse = ", ")
    ))
  })

  # the most similar signature

  output$selected_sig_full_2_1 <- renderPlot({
    visPMS_full_modified(sig_full[, rank1() + 3], 3, FALSE)
  })


  output$selected_sig_text_2_1 <- renderText({
    HTML(paste(
      "<b>Type:</b> COSIMIC signature ", paste0("C", rank1()), "</br>",
      "<b>Similarity(highest):</b> ", corr_mat[index2(), rank1()] %>% round(3), "</br>", "</b>",
      "<b>", "Cancer Membership:", "</b>",
      paste(names(which(cosmic_corr[rank1(), ] == 1)), collapse = ", ")
    ))
  })

  # self-defined signature
  output$selected2_1 <- renderValueBox({
    valueBox(
      paste0("P", index2()), "pmsignature",
      icon = icon("list"),
      color = "blue"
    )
  })

  output$highest2 <- renderValueBox({
    valueBox(
      paste0("C", rank1()), "Most simliar COSMIC", icon("thumbs-up", lib = "glyphicon"),
      color = "green"
    )
  })

  output$selected2_2 <- renderValueBox({
    valueBox(
      paste0("C", indexS2()), "COSMIC input",
      icon = icon("user"),
      color = "yellow"
    )
  })


  output$selected_sig_full_2_2 <- renderPlot({
    visPMS_full_modified(sig_full[, indexS2() + 3], 3, FALSE)
  })


  output$selected_sig_text_2_2 <- renderText({
    HTML(paste(
      "<b>Type:</b> COSIMIC signature ", paste0("C", indexS2()), "</br>",
      "<b>Similarity(selected):</b> ", corr_mat[index2(), indexS2()] %>% round(3), "</br>", "</b>",
      "<b>", "Cancer Membership:", "</b>",
      paste(names(which(cosmic_corr[indexS(), ] == 1)), collapse = ", ")
    ))
  })



  ##########
  # Page 3.1
  ##########
  fu_vector <- reactive({
    file1 <- input$file1
    
    if (is.null(file1))
      return(sig_full[,4])
    
    read.table(file=file1$datapath, header = input$header1)[,1]
  })
  
  
  output$similar_full <- renderPlot({
    visPMS_full_modified(fu_vector(), 3, FALSE)
  })

  corr_full <- reactive({
    corr_full <- rep(NA, dim(sig_full)[2] - 3)
    for (i in 1:(dim(sig_full)[2] - 3)) {
      corr_full[i] <- getCosDistance(fu_vector(), sig_full[, i + 3])
    }
    corr_full
  })

  corr_vec_full_pm <- reactive({
    corr_vec_full_pm <- rep(NA, length(Fs))
    for (i in 1:length(Fs)) {
      input_sig <- convertSignatureMatrixToVector(Fs[[i]][-6, ], c(6, 4, 4))
      corr_vec_full_pm[i] <- getCosDistance(fu_vector(), input_sig)
    }
    corr_vec_full_pm
  })

  output$fu_box <- renderValueBox({
    valueBox(
      max(corr_full()) %>% round(3) %>% sprintf("%1.3f", .),
      paste0("Similarity"),
      color = "blue"
    )
  })

  output$fu_box2 <- renderValueBox({
    valueBox(
      max(corr_vec_full_pm()) %>% round(3) %>% sprintf("%1.3f", .),
      paste0("Similarity"),
      color = "green"
    )
  })

  output$fu_table <- renderDataTable({
    table <- cbind(
      `COSMIC signature` = paste0("C", 1:length(corr_full())),
      `Cosine Similarity` = round(corr_full(), 3)
    )
    table <- table[order(table[, 2], decreasing = TRUE), ]
    rownames(table) <- NULL
    datatable(table, options = list(
      pageLength = 3, searching = FALSE,
      pagingType = "simple", lengthChange = FALSE
    )) %>%
      formatStyle(columns = 1:3, "text-align" = "center")
  }, server = TRUE)

  output$fu_table2 <- renderDataTable({
    table <- cbind(
      `pmsignature` = paste0("P", 1:length(corr_vec_full_pm())),
      `Cosine Similarity` = round(corr_vec_full_pm(), 3)
    )
    table <- table[order(table[, 2], decreasing = TRUE), ]
    rownames(table) <- NULL
    datatable(table, options = list(
      pageLength = 3, searching = FALSE,
      pagingType = "simple", lengthChange = FALSE
    )) %>%
      formatStyle(columns = 1:3, "text-align" = "center")
  }, server = TRUE)
  
  output$fu_text <- renderText({
    if (is.null(input$fu_table_rows_selected)){
      paste0("COSMIC signature C", which.max(corr_full()))
    }
    
      
  })
  
  output$fu_text2 <- renderText({
    paste0("pmsignature P", which.max(corr_vec_full_pm()))
  })
  
  output$fu_plot <- renderPlot({
    visPMS_full_modified(sig_full[, which.max(corr_full()) + 3], 3, FALSE)
  })
  
  output$fu_plot2 <- renderPlot({
    pmsignature:::visPMS_ind(Fs[[which.max(corr_vec_full_pm())]][-6, ], 5, isScale = TRUE)
  })
  
  output$selected_sig_text_3_1 <- renderText({
    HTML(paste(
      intersect(names(which(cosmic_corr[which.max(corr_full()), ] == 1)), 
                names(which(pm_corr[which.max(corr_vec_full_pm()), ] == 1))), collapse = ", "
    ))
  })
  
  output$selected_sig_text_3_2 <- renderText({
    HTML(paste0(
      setdiff(names(which(cosmic_corr[which.max(corr_full()), ] == 1)), 
              names(which(pm_corr[which.max(corr_vec_full_pm()), ] == 1))), collapse = ", "
    ))
  })

  output$selected_sig_text_3_3 <- renderText({
    HTML(paste(
      setdiff(names(which(pm_corr[which.max(corr_vec_full_pm()), ] == 1)), 
              names(which(cosmic_corr[which.max(corr_full()), ] == 1))), collapse = ", "
    ))
  })

  ##########
  # Page 3.2
  ##########
  
  pm_vector <- reactive({
    file2 <- input$file2
    
    if (is.null(file2))
      return(Fs[[1]][1:5,])
    
    read.table(file=file2$datapath, header = input$header2, sep = ",")
  })
  
  output$similar_pm <- renderPlot({
    pmsignature:::visPMS_ind(as.matrix(pm_vector()),
      5, isScale = TRUE
    )
  })

  corr_vec <- reactive({
    corr_vec <- rep(NA, length(Fs))
    for (i in 1:length(Fs)) {
      full_sig <- convertSignatureMatrixToVector(Fs[[i]], c(6, 4, 4, 4, 4))
      input_sig <- convertSignatureMatrixToVector(as.matrix(pm_vector()), c(6, 4, 4, 4, 4))
      corr_vec[i] <- getCosDistance(input_sig, full_sig)
    }
    corr_vec
  })

  corr_vec_full <- reactive({
    corr_vec_full <- rep(NA, dim(sig_full)[2] - 3)
    for (i in 1:(dim(sig_full)[2] - 3)) {
      input_sig <- convertSignatureMatrixToVector(as.matrix(pm_vector()), c(6, 4, 4))
      corr_vec_full[i] <- getCosDistance(input_sig, sig_full[, i + 3])
    }
    corr_vec_full
  })

  output$pm_box <- renderValueBox({
    valueBox(
      max(corr_vec()) %>% round(3) %>% sprintf("%1.3f", .),
      paste0("Similarity"),
      color = "blue"
    )
  })

  output$pm_box2 <- renderValueBox({
    valueBox(
      max(corr_vec_full()) %>% round(3) %>% sprintf("%1.3f", .),
      paste0("Similarity"),
      color = "green"
    )
  })

  output$pm_text <- renderText({
    paste0("pmsignature P", which.max(corr_vec()))
  })

  output$pm_text2 <- renderText({
    paste0("COSMIC signature C", which.max(corr_vec_full()))
  })

  output$pm_plot <- renderPlot({
    pmsignature:::visPMS_ind(Fs[[which.max(corr_vec())]][-6, ], 5, isScale = TRUE)
  })

  output$pm_plot2 <- renderPlot({
    visPMS_full_modified(sig_full[, which.max(corr_vec_full()) + 3], 3, FALSE)
  })

  output$pm_table <- renderDataTable({
    table <- cbind(
      `pmsignature` = paste0("P", 1:length(corr_vec())),
      `Cosine Similarity` = round(corr_vec(), 3)
    )
    table <- table[order(table[, 2], decreasing = TRUE), ]
    rownames(table) <- NULL
    datatable(table, options = list(
      pageLength = 3, searching = FALSE,
      pagingType = "simple", lengthChange = FALSE
    )) %>%
      formatStyle(columns = 1:3, "text-align" = "center")
  })

  output$pm_table2 <- renderDataTable({
    table <- cbind(
      `COSMIC signature` = paste0("C", 1:length(corr_vec_full())),
      `Cosine Similarity` = round(corr_vec_full(), 3)
    )
    table <- table[order(table[, 2], decreasing = TRUE), ]
    rownames(table) <- NULL
    datatable(table, options = list(
      pageLength = 3, searching = FALSE,
      pagingType = "simple", lengthChange = FALSE
    )) %>%
      formatStyle(columns = 1:3, "text-align" = "center")
  })
  
  
  output$selected_sig_text_4_1 <- renderText({
    HTML(paste(
      intersect(names(which(pm_corr[which.max(corr_vec()), ] == 1)), 
                names(which(cosmic_corr[which.max(corr_vec_full()), ] == 1))), collapse = ", "
    ))
  })
  
  output$selected_sig_text_4_2 <- renderText({
    HTML(paste0(
      setdiff(names(which(pm_corr[which.max(corr_vec()), ] == 1)), 
              names(which(cosmic_corr[which.max(corr_vec_full()), ] == 1))), collapse = ", "
    ))
  })
  
  output$selected_sig_text_4_3 <- renderText({
    HTML(paste(
      setdiff(names(which(cosmic_corr[which.max(corr_vec_full()), ] == 1)), 
              names(which(pm_corr[which.max(corr_vec()), ] == 1))), collapse = ", "
    ))
  })
  
  
  output$downloadData <- downloadHandler(
    filename = function() {
      "cosmic_signature_sample.csv"
    },
    content = function(file) {
      file.copy("samples/cosmic_signature_sample.csv", file)
    },
    contentType = "text/csv"
  )
  
  output$downloadData2 <- downloadHandler(
    filename = function() {
      "pmsignature_sample.csv"
    },
    content = function(file) {
      file.copy("samples/pmsignature_sample.csv", file)
    },
    contentType = "text/csv"
  )
  
  
}

# Double check the title again
# plot bottom is not reactive
# implement importing csv file (R users and non-R users)
# color blind for the pmsignature