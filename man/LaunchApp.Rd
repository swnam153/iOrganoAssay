% Generated manually for iOrganoAssay
\name{LaunchApp}
\alias{LaunchApp}
\title{Launch the iOrganoAssay Shiny Application}
\usage{
LaunchApp(launch.browser = TRUE, port = NULL)
}
\arguments{
\item{launch.browser}{Logical. If \code{TRUE} (default), the app is opened
in the user's default web browser. If \code{FALSE}, it runs in the
RStudio Viewer pane.}

\item{port}{Integer. Optional TCP port to run the app on. If \code{NULL}
(default), \code{shiny} chooses a random free port.}
}
\value{
This function is called for its side effect (launching the Shiny app)
and does not return a value.
}
\description{
\code{LaunchApp} starts the iOrganoAssay Shiny application that is
bundled inside the \pkg{iOrganoAssay} package. The user does not need to
copy or paste any script; calling this function launches the GUI
directly in the default browser (or the RStudio Viewer pane).
}
\examples{
\dontrun{
  library(iOrganoAssay)
  LaunchApp()
}
}
