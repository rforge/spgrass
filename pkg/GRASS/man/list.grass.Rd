% Copyright 2003 by Roger S. Bivand
%
\name{list.grass}
\alias{list.grass}
\alias{print.glist}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{List GRASS database elements}
\description{
  A helper function to list GRASS database elements, using compiled access to GRASS - for an interpreted alternative use system("g.list").
}
\usage{
list.grass(type = "cell")
\method{print}{glist}(x, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{type}{one of "cell", "site\_lists", or "dig\_plus"}
  \item{x}{a glist object returned by list.grass()}
  \item{...}{arguments passed to print methods}
}
\value{
  A glist object, a named list of database elements in character vectors, one character vector for each MAPSET in the mapsets returned by get.mapsets()
}
\references{\url{http://grass.itc.it/statsgrass/index.html}}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}
\keyword{spatial}
