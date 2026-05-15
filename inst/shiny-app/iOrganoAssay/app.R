#-----------------------------
# iOrganoAssay Shiny App
# Bundled inside the iOrganoAssay package
#-----------------------------

library(shiny)
library(dplyr)
library(ggplot2)
library(readxl)
library(stringr)
library(tools)
library(magick)

#-----------------------------
# default path
#-----------------------------

DEFAULT_IMG <- "C:/iOrganoAssay/1.Microscopy"
DEFAULT_SEG <- "C:/iOrganoAssay/2.Segmentation"
DEFAULT_MET <- "C:/iOrganoAssay/3.Metrics"

#-----------------------------
# metric reading
#-----------------------------
read_metric_vector <- function(path, metric) {
  if (!file.exists(path)) {
    return(NULL)
  }

  sheet <- switch(metric,
                  "area" = "Outline Area (\u00b5m\u00b2)",
                  "perimeter" = "Perimeter (\u00b5m)",
                  "circularity" = "Circularity"
  )

  df <- read_excel(path, sheet = sheet)

  if (!("Frame 0" %in% colnames(df))) {
    return(NULL)
  }

  df[["Frame 0"]]
}

#-----------------------------
# UI
#-----------------------------
ui <- navbarPage(
  title = "iOrganoAssay",
  header = tags$head(
    tags$style(HTML("
      .navbar-brand { font-weight: bold; }
      #ui_css_dynamic { font-size: 14px; }
    ")),
    uiOutput("dynamic_fontsize")
  ),

  tabPanel(
    "Analysis",
    tags$div(id = "main_content_area",
             uiOutput("dynamic_fontsize"),
             sidebarLayout(
               sidebarPanel(
                 h4("1. Metafile"),
                 fileInput("meta", "Upload metafile"),
                 hr(),
                 h4("2. Folder setting"),
                 textInput("img_dir", "C:/iOrganoAssay/1.Microscopy", DEFAULT_IMG),
                 textInput("seg_dir", "C:/iOrganoAssay/2.Segmentation", DEFAULT_SEG),
                 textInput("met_dir", "C:/iOrganoAssay/3.Metrics", DEFAULT_MET),
                 hr(),
                 h4("3. Category condition"),
                 selectInput("mice", "Mice", choices = NULL),
                 selectInput("passage", "Passage", choices = NULL),
                 selectInput("well", "Microwell",
                             choices = NULL,
                             multiple = TRUE
                 ),
                 selectInput("day", "Day", choices = NULL),
                 actionButton("apply", "Apply"),
                 hr(),
                 h4("4. Metric"),
                 selectInput("metric", "Metric",
                             choices = c("area", "perimeter", "circularity")
                 ),
                 hr(),
                 h4("5. Plot control"),
                 sliderInput("pt_size", "Point size", 1, 10, 3),
                 sliderInput("line_size", "Line size", 0.5, 5, 1),
                 sliderInput("axis_size", "Axis text size", 8, 30, 12),
                 sliderInput("title_size", "Title size", 10, 30, 14),
                 sliderInput("axis_line_size", "Axis line thickness",
                             min = 0.2, max = 3, value = 1, step = 0.1
                 ),
                 sliderInput("violin_pt", "Violin dot size", 0.5, 5, 1),
                 sliderInput("violin_line", "Line size", 0.5, 5, 1),
                 sliderInput("violin_axis", "Axis text size", 8, 30, 12),
                 sliderInput("violin_title", "Title size", 10, 30, 14),
                 sliderInput("legend_size", "Legend text size", 8, 30, 10),
                 sliderInput("ui_font_size", "All fonts size (px)", min = 10, max = 30, value = 14)
               ),
               mainPanel(
                 h4("Microscopy Images"),
                 uiOutput("images"),
                 hr(),
                 h4("Segmentation Images"),
                 uiOutput("seg_images"),
                 hr(),
                 h4("Mean + Std Plot"),
                 plotOutput("meanPlot", height = "300px"),
                 hr(),
                 h4("Violin Plot"),
                 plotOutput("violinPlot", height = "400px"),
                 hr(),
                 h4("Download plots"),
                 downloadButton("download_mean", "Download Daily graph (JPEG)"),
                 downloadButton("download_violin", "Download Violin plot (JPEG)")
               )
             )
    )
  ),
  tabPanel(
    "Validation",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          width = 3,
          h5("Validation Set 1"),
          fileInput("orFile", "Original image file",
                    accept = c(".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".png")
          ),
          fileInput("gtFile", "Ground truth image file",
                    accept = c(".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".png")
          ),
          fileInput("segFile", "Segmentation image file",
                    accept = c(".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".png")
          ),
          tags$div(id = "dynamic_inputs"),
          actionButton("valBtn", "Apply"),
          actionButton("addBtn", "Add"),
          actionButton("removeBtn", "Remove")
        ),
        mainPanel(
          width = 9,
          h4(paste("Validation Set 1 Results")),
          fluidRow(
            column(2,
                   align = "center",
                   style = "padding: 0px 2px;",
                   h4("Original image"),
                   imageOutput("img_Or", height = "auto")
            ),
            column(2,
                   align = "center",
                   style = "padding: 0px 2px;",
                   h4("Ground Truth"),
                   imageOutput("img_gt", height = "auto")
            ),
            column(2,
                   align = "center",
                   style = "padding: 0px 2px;",
                   h4("Segmentation"),
                   imageOutput("img_seg", height = "auto")
            ),
            column(6,
                   style = "padding: 0px 2px;",
                   h4("Evaluation Metrics"),
                   verbatimTextOutput("valMetrics")
            )
          ),
          tags$div(id = "dynamic_outputs")
        )
      )
    )
  )
)


#-----------------------------
# SERVER
#-----------------------------
server <- function(input, output, session) {

  observe({
    if (!dir.exists(input$img_dir)) {
      showNotification("IMG folder does not exist", type = "warning")
    } else {
      addResourcePath("img", input$img_dir)
    }

    if (!dir.exists(input$seg_dir)) {
      showNotification("SEG folder does not exist", type = "warning")
    } else {
      addResourcePath("seg", input$seg_dir)
    }
  })


  # metadata
  meta <- reactive({
    req(input$meta)
    read_excel(input$meta$datapath)
  })


  # dropdown
  observe({
    df <- meta()

    updateSelectInput(session, "mice",
                      choices = c("All", unique(df$mice))
    )

    updateSelectInput(session, "passage",
                      choices = c("All", unique(df$passage))
    )

    updateSelectInput(session, "day",
                      choices = c("All", unique(df$day))
    )

    updateSelectInput(session, "well",
                      choices = unique(df$microwell)
    )
  })

  # filtering
  filtered <- eventReactive(input$apply, {

    df <- meta()

    if(input$mice != "All") df <- df %>% filter(mice == input$mice)
    if(input$passage != "All") df <- df %>% filter(passage == input$passage)
    if(input$day != "All") df <- df %>% filter(day == input$day)

    # microwell selection

    if(length(input$well) > 0){
      df <- df %>% filter(microwell %in% input$well)

      # enforce user input order
      df$microwell <- factor(df$microwell, levels = input$well)

    }

    # numeric ordering of day
    df$day_num <- as.numeric(stringr::str_extract(df$day, "\\d+"))

    df %>% arrange(microwell, day_num)

  })

  #-----------------------------
  # RAW images (Grid)
  #-----------------------------
  output$images <- renderUI({
    df <- filtered()
    req(df)

    files <- df$filename


    tags$div(
      style = "display:flex; flex-wrap:wrap; gap:15px;",
      lapply(files, function(f) {
        tags$div(
          style = "text-align:center;",
          tags$p(f, style = "font-size:10px;"),
          tags$img(
            src = file.path("img", f),
            style = "width:120px;"
          )
        )
      })
    )
  })

  #-----------------------------
  # SEG images (Grid)
  #-----------------------------
  output$seg_images <- renderUI({
    df <- filtered()
    req(df)

    files <- df$filename


    tags$div(
      style = "display:flex; flex-wrap:wrap; gap:15px;",
      lapply(files, function(f) {
        tags$div(
          style = "text-align:center;",
          tags$p(f, style = "font-size:10px;"),
          tags$img(
            src = file.path("seg", f),
            style = "width:120px;"
          )
        )
      })
    )
  })


  #-----------------------------
  # Mean plot
  #-----------------------------
  output$meanPlot <- renderPlot({
    df <- filtered()
    req(df)

    df$day_num <- as.numeric(str_extract(df$day, "\\d+"))

    df$value <- sapply(df$filename, function(f) {
      path <- file.path(
        input$met_dir,
        paste0(file_path_sans_ext(f), "_metrics.xlsx")
      )

      v <- read_metric_vector(path, input$metric)
      if (is.null(v)) {
        return(NA)
      }

      mean(v, na.rm = TRUE)
    })

    df$sd <- sapply(df$filename, function(f) {
      path <- file.path(
        input$met_dir,
        paste0(file_path_sans_ext(f), "_metrics.xlsx")
      )

      v <- read_metric_vector(path, input$metric)
      if (is.null(v)) {
        return(NA)
      }

      sd(v, na.rm = TRUE)
    })

    ggplot(df, aes(
      x = day_num, y = value,
      color = microwell, group = microwell
    )) +
      geom_point(size = input$pt_size) +
      geom_line(linewidth = input$line_size) +
      geom_errorbar(
        aes(
          ymin = value - sd,
          ymax = value + sd
        ),
        width = 0.2
      ) +
      scale_x_continuous(
        breaks = df$day_num,
        labels = df$day
      ) +
      theme_minimal() +
      theme(
        axis.text = element_text(size = input$axis_size),
        axis.title = element_text(size = input$title_size),
        axis.line = element_line(size = input$axis_line_size, color = "black"),
        axis.ticks = element_line(size = input$axis_line_size),
        legend.text = element_text(size = input$legend_size),
        legend.title = element_text(size = input$legend_size + 2)
      )
  })

  #-----------------------------
  #  Violin plot
  #-----------------------------
  output$violinPlot <- renderPlot({
    df <- filtered()
    req(nrow(df) > 0)

    all_data <- data.frame()

    for (i in 1:nrow(df)) {
      f <- df$filename[i]

      path <- file.path(
        input$met_dir,
        paste0(file_path_sans_ext(f), "_metrics.xlsx")
      )

      v <- read_metric_vector(path, input$metric)

      if (!is.null(v)) {
        tmp <- data.frame(
          value = v,
          day = df$day[i],
          microwell = df$microwell[i]
        )

        all_data <- rbind(all_data, tmp)
      }
    }

    ggplot(
      all_data,
      aes(x = day, y = value, fill = microwell)
    ) +
      geom_violin(
        position = position_dodge(0.8),
        alpha = 0.5
      ) +
      geom_jitter(aes(color = microwell),
                  position = position_jitterdodge(
                    jitter.width = 0.1,
                    dodge.width = 0.8
                  ),
                  size = input$violin_pt,
                  alpha = 0.4
      ) +
      theme_minimal() +
      theme(
        axis.text = element_text(size = input$violin_axis),
        axis.title = element_text(size = input$violin_title),
        axis.line = element_line(size = input$axis_line_size, color = "black"),
        axis.ticks = element_line(size = input$axis_line_size),
        legend.text = element_text(size = input$legend_size),
        legend.title = element_text(size = input$legend_size + 2)
      )
  })

  #-----------------------------
  # Download handlers
  #-----------------------------

  output$download_mean <- downloadHandler(
    filename = function() {
      paste0("Daily_monitoring_", Sys.Date(), ".jpeg")
    },
    content = function(file) {
      df <- filtered()
      req(df)

      df$day_num <- as.numeric(str_extract(df$day, "\\d+"))

      df$value <- sapply(df$filename, function(f) {
        path <- file.path(
          input$met_dir,
          paste0(file_path_sans_ext(f), "_metrics.xlsx")
        )
        v <- read_metric_vector(path, input$metric)
        if (is.null(v)) {
          return(NA)
        }
        mean(v, na.rm = TRUE)
      })

      df$sd <- sapply(df$filename, function(f) {
        path <- file.path(
          input$met_dir,
          paste0(file_path_sans_ext(f), "_metrics.xlsx")
        )
        v <- read_metric_vector(path, input$metric)
        if (is.null(v)) {
          return(NA)
        }
        sd(v, na.rm = TRUE)
      })

      p <- ggplot(df, aes(
        x = day_num, y = value,
        color = microwell, group = microwell
      )) +
        geom_point(size = input$pt_size) +
        geom_line(linewidth = input$line_size) +
        geom_errorbar(aes(
          ymin = value - sd,
          ymax = value + sd
        ), width = 0.2) +
        scale_x_continuous(
          breaks = df$day_num,
          labels = df$day
        ) +
        theme_minimal()

      ggsave(file,
             plot = p, device = "jpeg",
             width = 8, height = 5, dpi = 300
      )
    }
  )


  output$download_violin <- downloadHandler(
    filename = function() {
      paste0("Violin_plot_", Sys.Date(), ".jpeg")
    },
    content = function(file) {
      df <- filtered()
      req(nrow(df) > 0)

      all_data <- data.frame()

      for (i in 1:nrow(df)) {
        f <- df$filename[i]

        path <- file.path(
          input$met_dir,
          paste0(file_path_sans_ext(f), "_metrics.xlsx")
        )

        v <- read_metric_vector(path, input$metric)

        if (!is.null(v)) {
          tmp <- data.frame(
            value = v,
            day = df$day[i],
            microwell = df$microwell[i]
          )
          all_data <- rbind(all_data, tmp)
        }
      }

      p <- ggplot(
        all_data,
        aes(x = day, y = value, fill = microwell)
      ) +
        geom_violin(position = position_dodge(0.8), alpha = 0.5) +
        geom_jitter(aes(color = microwell),
                    position = position_jitterdodge(
                      jitter.width = 0.1,
                      dodge.width = 0.8
                    ),
                    size = input$violin_pt,
                    alpha = 0.4
        ) +
        theme_minimal()

      ggsave(file,
             plot = p, device = "jpeg",
             width = 8, height = 6, dpi = 300
      )
    }
  )

  #-----------------------------
  # Validation Images (Dynamic)
  #-----------------------------
  val_count <- reactiveVal(1)

  observeEvent(input$addBtn, {
    count <- val_count() + 1
    val_count(count)

    # insertUI for Inputs
    insertUI(
      selector = "#dynamic_inputs",
      where = "beforeEnd",
      ui = tags$div(
        id = paste0("dyn_in_", count),
        hr(),
        h5(paste("Validation Set", count)),
        fileInput(paste0("orFile_", count), "Original image file", accept = c(".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".png")),
        fileInput(paste0("gtFile_", count), "Ground truth image file", accept = c(".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".png")),
        fileInput(paste0("segFile_", count), "Segmentation image file", accept = c(".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".png"))
      )
    )

    # insertUI for Outputs
    insertUI(
      selector = "#dynamic_outputs",
      where = "beforeEnd",
      ui = tags$div(
        id = paste0("dyn_out_", count),
        hr(style = "margin-top: 20px; margin-bottom: 20px; border-top: 2px solid #ccc;"),
        h4(paste("Validation Set", count, "Results")),
        fluidRow(
          column(2, align = "center", style = "padding: 0px 2px;", imageOutput(paste0("img_Or_", count), height = "auto")),
          column(2, align = "center", style = "padding: 0px 2px;", imageOutput(paste0("img_gt_", count), height = "auto")),
          column(2, align = "center", style = "padding: 0px 2px;", imageOutput(paste0("img_seg_", count), height = "auto")),
          column(6, style = "padding: 0px 2px;", verbatimTextOutput(paste0("valMetrics_", count)))
        )
      )
    )
  })

  observeEvent(input$removeBtn, {
    count <- val_count()
    if (count > 1) {
      removeUI(selector = paste0("#dyn_in_", count))
      removeUI(selector = paste0("#dyn_out_", count))
      val_count(count - 1)
    }
  })

  output$dynamic_fontsize <- renderUI({
    req(input$ui_font_size)
    tags$style(HTML(paste0(
      ".navbar-brand { font-size: ", input$ui_font_size + 8, "px !important; }",
      ".navbar-nav li a { font-size: ", input$ui_font_size + 2, "px !important; }",
      "body, label, input, button, select, .form-control { font-size: ", input$ui_font_size, "px !important; }",
      "h4 { font-size: ", input$ui_font_size + 4, "px !important; font-weight: bold; }",
      "h5 { font-size: ", input$ui_font_size + 2, "px !important; }"
    )))
  })

  observeEvent(input$valBtn, {
    count_total <- val_count()

    for (i in 1:count_total) {
      local({
        idx <- i

        or_id <- if (idx == 1) "orFile" else paste0("orFile_", idx)
        gt_id <- if (idx == 1) "gtFile" else paste0("gtFile_", idx)
        seg_id <- if (idx == 1) "segFile" else paste0("segFile_", idx)

        img_or_id <- if (idx == 1) "img_Or" else paste0("img_Or_", idx)
        img_gt_id <- if (idx == 1) "img_gt" else paste0("img_gt_", idx)
        img_seg_id <- if (idx == 1) "img_seg" else paste0("img_seg_", idx)
        metrics_id <- if (idx == 1) "valMetrics" else paste0("valMetrics_", idx)

        output[[img_or_id]] <- renderImage(
          {
            req(input[[or_id]])
            list(src = input[[or_id]]$datapath, contentType = input[[or_id]]$type, width = "100%", alt = "Original Image")
          },
          deleteFile = FALSE
        )

        output[[img_gt_id]] <- renderImage(
          {
            req(input[[gt_id]])
            list(src = input[[gt_id]]$datapath, contentType = input[[gt_id]]$type, width = "100%", alt = "Ground Truth Image")
          },
          deleteFile = FALSE
        )

        output[[img_seg_id]] <- renderImage(
          {
            req(input[[seg_id]])
            list(src = input[[seg_id]]$datapath, contentType = input[[seg_id]]$type, width = "100%", alt = "Segmentation Image")
          },
          deleteFile = FALSE
        )

        output[[metrics_id]] <- renderPrint({
          req(input[[gt_id]], input[[seg_id]])

          segRaw <- image_data(image_convert(image_read(input[[seg_id]]$datapath), colorspace = "gray"))[1, , ]
          gtRaw <- image_data(image_convert(image_read(input[[gt_id]]$datapath), colorspace = "gray"))[1, , ]

          segMat <- as.numeric(segRaw) / 255
          gtMat <- as.numeric(gtRaw) / 255
          dim(segMat) <- dim(segRaw)
          dim(gtMat) <- dim(gtRaw)

          segBin <- segMat > 0.5
          gtBin <- gtMat > 0.5

          intersection <- sum(segBin == 1 & gtBin == 1)
          gt_pixels <- sum(gtBin == 1)
          fn_pixels <- sum(gtBin == 1 & segBin == 0)

          epsilon <- 1e-7

          if ((sum(segBin) + sum(gtBin)) == 0) {
            dice <- 1.0
          } else {
            dice <- (2 * intersection) / (sum(segBin) + sum(gtBin))
          }

          acc_c <- intersection / (gt_pixels + epsilon)
          segErr_c <- fn_pixels / (gt_pixels + epsilon)

          get_centroid <- function(bin_mat) {
            indices <- which(bin_mat == TRUE, arr.ind = TRUE)
            if (is.null(nrow(indices)) || nrow(indices) == 0) {
              return(c(NA, NA))
            }
            return(colMeans(indices))
          }

          cen_seg <- get_centroid(segBin)
          cen_gt <- get_centroid(gtBin)

          if (any(is.na(cen_seg)) || any(is.na(cen_gt))) {
            cenErr_c <- NA
          } else {
            abs_dist <- sqrt(sum((cen_seg - cen_gt)^2))
            diag_length <- sqrt(nrow(segMat)^2 + ncol(segMat)^2)
            cenErr_c <- abs_dist / (diag_length + epsilon)
          }

          cat(paste0("=== Validation Set ", idx, " Evaluation ===\n"))
          cat("1. DICE Score (LocDice):", round(dice, 4), "\n")
          cat("2. Object Accuracy:     ", round(acc_c, 4), "\n")
          cat("3. Object Seg Error:    ", round(segErr_c, 4), "\n")
          cat("4. Normalized CenErr:   ", round(cenErr_c, 6), "(ratio)\n")
        })
      })
    }
  })
}

shinyApp(ui, server)
