#' Launch the iOrganoAssay Shiny Application
#'
#' \code{LaunchApp} starts the iOrganoAssay Shiny application that is
#' bundled inside the \pkg{iOrganoAssay} package. The user does not need
#' to copy or paste any script; calling this function launches the GUI
#' directly in the default browser (or the RStudio Viewer pane).
#'
#' The application contains two tabs:
#' \itemize{
#'   \item \strong{Analysis} -- daily-based monitoring of mouse intestinal
#'         organoid (mIO) morphology with mean and violin plots.
#'   \item \strong{Validation} -- evaluation of segmentation quality using
#'         Dice score, object accuracy, segmentation error, and normalized
#'         centroid error.
#' }
#'
#' @param launch.browser Logical. If \code{TRUE} (default), the app is
#'   opened in the user's default web browser. If \code{FALSE}, it
#'   runs in the RStudio Viewer pane.
#' @param port Integer. Optional TCP port to run the app on. If
#'   \code{NULL} (default), \code{shiny} chooses a random free port.
#'
#' @return This function is called for its side effect (launching the
#'   Shiny app) and does not return a value.
#'
#' @examples
#' \dontrun{
#'   library(iOrganoAssay)
#'   LaunchApp()
#' }
#'
#' @export
LaunchApp <- function(launch.browser = TRUE, port = NULL) {

  app_dir <- system.file("shiny-app", "iOrganoAssay",
                         package = "iOrganoAssay")

  if (app_dir == "" || !dir.exists(app_dir)) {
    stop("Could not find the iOrganoAssay Shiny app directory. ",
         "Try re-installing the package with ",
         "remotes::install_github(\"swnam153/iOrganoAssay\").",
         call. = FALSE)
  }

  shiny::runApp(appDir         = app_dir,
                launch.browser = launch.browser,
                port           = port)
}
