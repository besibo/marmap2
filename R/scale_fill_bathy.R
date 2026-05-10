#' Bathymetry colour scales for ggplot2
#'
#' @description
#' `scale_fill_bathy()` provides perceptually ordered colour scales for
#' bathymetric and topographic rasters drawn with ggplot2. The ocean and land
#' parts of the scale are selected independently:
#'
#' - use a palette name to map a side with a colour gradient;
#' - use a single colour name or code to draw a side with a constant colour;
#' - use `NULL` to leave a side undefined;
#' - use both `palette_ocean` and `palette_land` to map depths and altitudes
#'   with separate palettes joined at sea level.
#'
#' @param palette_ocean,palette_land Palette definition used for ocean values
#'   (`<= 0`) and land values (`>= 0`), respectively. Can be a palette name, a
#'   single colour, a vector of colours, a function taking `n` and returning
#'   colours, or `NULL`.
#' @param limits Numeric vector of length two. Limits of the fill scale. If
#'   `NULL`, the scale limits are trained from the plotted data.
#' @param mode Character. Either `"rescale"` or `"truncate"`. With
#'   `"truncate"`, the legend spans the data range but colours remain anchored
#'   to fixed bathymetric/topographic reference depths, so the same depth or
#'   altitude keeps the same colour across maps. With `"rescale"`, the selected
#'   palette part is stretched over the plotted data range.
#' @param na.value Colour used for missing values.
#' @param name Scale name passed to
#'   \code{\link[ggplot2:scale_gradient]{ggplot2::scale_fill_gradientn}}.
#' @param oob Function used for out-of-bounds values. If `NULL`, values are
#'   squished to the nearest scale limit.
#' @param ... Additional arguments passed to
#'   \code{\link[ggplot2:scale_gradient]{ggplot2::scale_fill_gradientn}}.
#'
#' @return A ggplot2 fill scale.
#'
#' @seealso
#' \code{\link{geom_bathy}}, \code{\link{bathy_palette}},
#' \code{\link{bathy_palettes}}
#'
#' @examples
#' \dontrun{
#' dat |>
#'   ggplot2::ggplot() +
#'   geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
#'   scale_fill_bathy(palette_land = "grey85")
#'
#' dat |>
#'   ggplot2::ggplot() +
#'   geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
#'   scale_fill_bathy(
#'     palette_ocean = "ocean_blues",
#'     palette_land = "land_hcl"
#'   )
#'
#' dat |>
#'   ggplot2::ggplot() +
#'   geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
#'   scale_fill_bathy(palette_ocean = "#D8EEF3", palette_land = "land_hcl")
#'
#' dat |>
#'   ggplot2::ggplot() +
#'   geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
#'   scale_fill_bathy(
#'     palette_ocean = grDevices::hcl.colors(256, "Blues 3"),
#'     palette_land = function(n) grDevices::hcl.colors(n, "Terrain 2")
#'   )
#' }
#' @export
scale_fill_bathy <- function(
  palette_ocean = "ocean_blues",
  palette_land = "land_earth",
  limits = NULL,
  mode = c("rescale", "truncate"),
  na.value = "grey90",
  name = "depth",
  oob = NULL,
  ...
) {
  mode <- match.arg(mode)
  spec <- bathy_scale_spec(palette_ocean, palette_land)
  limits <- bathy_user_limits(limits, spec$coverage)
  reference_limits <- bathy_reference_limits(spec$coverage)
  scale <- bathy_scale_values(spec, reference_limits, mode)
  rescaler <- bathy_scale_rescaler(spec$coverage, reference_limits, mode)
  if (is.null(oob)) {
    oob <- bathy_squish
  }

  ggplot2::scale_fill_gradientn(
    colours = scale$colours,
    values = scale$values,
    limits = limits,
    rescaler = rescaler,
    na.value = na.value,
    name = name,
    oob = oob,
    ...
  )
}

#' @rdname scale_fill_bathy
#' @param palette Palette name, single colour, colour vector, or function
#'   taking `n` and returning colours.
#' @param n Integer. Number of colours returned by `bathy_palette()`.
#'
#' @return
#' For `bathy_palette()`, a character vector of colours. For
#' `bathy_palettes()`, a character vector of palette names.
#'
#' @export
bathy_palette <- function(palette = "ocean_blues", n = 256) {
  spec <- bathy_palette_from_input(palette)
  if (identical(spec$type, "colour")) {
    return(rep(spec$colours[1], n))
  }
  grDevices::colorRampPalette(spec$colours)(n)
}

#' @rdname scale_fill_bathy
#' @param type Character. Palette family to list. One of `"all"`, `"ocean"`,
#'   or `"land"`.
#'
#' @export
bathy_palettes <- function(type = c("all", "ocean", "land")) {
  type <- match.arg(type)
  names <- names(bathy_palette_specs())
  if (identical(type, "all")) {
    return(names)
  }
  names[startsWith(names, paste0(type, "_"))]
}

bathy_palette_specs <- function() {
  list(
    ocean_blues = list(
      colours = c(
        "#00366C",
        "#005D9A",
        "#2C86CA",
        "#79ABE2",
        "#ADCCF6",
        "#D8E9FF",
        "#F9F9F9"
      )
    ),
    ocean_teal = list(
      colours = c(
        "#14505C",
        "#226B70",
        "#348781",
        "#4CA38F",
        "#6BBE99",
        "#9AD4A8",
        "#C7E5BE"
      )
    ),
    ocean_deep = list(
      colours = c(
        "#070707",
        "#392243",
        "#404B7B",
        "#007FA8",
        "#00AFB2",
        "#87D4BC",
        "#E0F7E1"
      )
    ),
    ocean_mako = list(
      colours = c(
        "#0B0B0C",
        "#22283D",
        "#244B6B",
        "#1C7191",
        "#2499A2",
        "#6BC4B1",
        "#D7F2DB"
      )
    ),
    ocean_ice = list(
      colours = c(
        "#10243E",
        "#1E4768",
        "#356D8B",
        "#5A93A9",
        "#8AB9C6",
        "#C3DEE4",
        "#F2F8F9"
      )
    ),
    ocean_mint = list(
      colours = c(
        "#163E48",
        "#245C60",
        "#367A72",
        "#509984",
        "#78B896",
        "#AAD5B2",
        "#E0EFD5"
      )
    ),
    land_hcl = list(
      colours = c(
        "#F7F3DF",
        "#DEC79D",
        "#BD7864",
        "#A15558",
        "#7A374C",
        "#541C3A",
        "#E2E2E2"
      )
    ),
    land_earth = list(
      colours = c(
        "#F7F3DF",
        "#E6D2A3",
        "#C8AA6E",
        "#9B7A4D",
        "#6F5946",
        "#4A3F3C",
        "#E2E2E2"
      )
    ),
    land_green = list(
      colours = c(
        "#FEFEE3",
        "#EAF5CA",
        "#C2E2A2",
        "#85C876",
        "#40A45D",
        "#0A764E",
        "#E2E2E2"
      )
    ),
    land_sand = list(
      colours = c(
        "#F8F1D7",
        "#E9D5A5",
        "#D2B476",
        "#B58E55",
        "#876843",
        "#594739",
        "#E6E3DD"
      )
    ),
    land_olive = list(
      colours = c(
        "#F7F3D2",
        "#D9DEA3",
        "#AFC06F",
        "#819849",
        "#5F7038",
        "#444D32",
        "#DFDFD8"
      )
    ),
    land_brown = list(
      colours = c(
        "#F4EAD0",
        "#D9BD8A",
        "#B9905B",
        "#8D6844",
        "#604935",
        "#3B332E",
        "#DFDFDF"
      )
    )
  )
}

bathy_palette_spec <- function(palette) {
  specs <- bathy_palette_specs()
  palette <- match.arg(palette, names(specs))
  specs[[palette]]
}

bathy_scale_spec <- function(palette_ocean, palette_land) {
  ocean <- bathy_scale_side(palette_ocean, "ocean")
  land <- bathy_scale_side(palette_land, "land")
  if (is.null(ocean) && is.null(land)) {
    stop(
      "At least one of palette_ocean or palette_land must be provided.",
      call. = FALSE
    )
  }

  coverage <- if (!is.null(ocean) && !is.null(land)) {
    "both"
  } else if (!is.null(ocean)) {
    "ocean"
  } else {
    "land"
  }

  list(
    coverage = coverage,
    ocean = ocean,
    land = land
  )
}

bathy_scale_side <- function(palette, side) {
  if (is.null(palette)) {
    return(NULL)
  }
  spec <- tryCatch(
    bathy_palette_from_input(palette),
    error = function(e) {
      stop(
        "palette_",
        side,
        " must be a palette name, colour, colour vector, function, or NULL.",
        call. = FALSE
      )
    }
  )
  spec
}

bathy_palette_from_input <- function(palette, n = 256) {
  if (is.function(palette)) {
    colours <- palette(n)
    return(bathy_palette_from_colour_vector(colours, type = "function"))
  }

  if (!is.character(palette) || length(palette) < 1 || anyNA(palette)) {
    stop(
      "palette must be a palette name, colour, colour vector, or function.",
      call. = FALSE
    )
  }

  if (length(palette) == 1) {
    specs <- bathy_palette_specs()
    if (palette %in% names(specs)) {
      spec <- specs[[palette]]
      spec$type <- "palette"
      spec$name <- palette
      return(spec)
    }
  }

  bathy_palette_from_colour_vector(
    palette,
    type = if (length(palette) == 1) "colour" else "vector"
  )
}

bathy_palette_from_colour_vector <- function(colours, type) {
  if (
    !is.character(colours) ||
      length(colours) < 1 ||
      anyNA(colours) ||
      !all(bathy_is_colour(colours))
  ) {
    stop("palette colours must be valid R colours.", call. = FALSE)
  }
  if (length(colours) == 1) {
    colours <- rep(colours, 2)
    type <- "colour"
  }
  list(
    colours = colours,
    type = type,
    name = NULL
  )
}

bathy_is_colour <- function(x) {
  ok <- try(grDevices::col2rgb(x), silent = TRUE)
  !inherits(ok, "try-error")
}

bathy_user_limits <- function(limits, coverage) {
  if (is.null(limits)) {
    return(NULL)
  }
  if (
    !is.numeric(limits) ||
      length(limits) != 2 ||
      anyNA(limits) ||
      any(!is.finite(limits))
  ) {
    stop("limits must be a finite numeric vector of length two.", call. = FALSE)
  }
  limits <- sort(limits)

  if (identical(coverage, "both") && !(limits[1] < 0 && limits[2] > 0)) {
    stop(
      "Using both ocean and land palettes requires limits spanning zero.",
      call. = FALSE
    )
  }
  if (identical(coverage, "ocean") && limits[2] <= 0) {
    limits[2] <- max(abs(limits[1]) * 1e-5, 0.1)
  }
  if (identical(coverage, "land") && limits[1] >= 0) {
    limits[1] <- -max(abs(limits[2]) * 1e-5, 0.1)
  }

  limits
}

bathy_reference_limits <- function(coverage) {
  switch(
    coverage,
    ocean = c(-11000, 0.1),
    land = c(-0.1, 9000),
    both = c(-11000, 9000)
  )
}

bathy_scale_values <- function(spec, limits, mode) {
  if (identical(spec$coverage, "ocean")) {
    zero <- bathy_coverage_zero("ocean", limits, mode)
    colours <- c(
      spec$ocean$colours,
      bathy_constant_side_colour(spec$land, "grey80")
    )
    values <- c(seq(0, zero, length.out = length(spec$ocean$colours)), 1)
  } else if (identical(spec$coverage, "land")) {
    zero <- bathy_coverage_zero("land", limits, mode)
    colours <- c(
      bathy_constant_side_colour(spec$ocean, "#D8EEF3"),
      spec$land$colours
    )
    values <- c(0, seq(zero, 1, length.out = length(spec$land$colours)))
  } else {
    zero <- bathy_coverage_zero("both", limits, mode)
    eps <- sqrt(.Machine$double.eps)
    colours <- c(spec$ocean$colours, spec$land$colours)
    values <- c(
      seq(0, zero, length.out = length(spec$ocean$colours)),
      seq(min(zero + eps, 1), 1, length.out = length(spec$land$colours))
    )
  }

  list(colours = colours, values = values)
}

bathy_constant_side_colour <- function(side, default) {
  if (is.null(side)) {
    return(default)
  }
  side$colours[length(side$colours)]
}

bathy_coverage_zero <- function(coverage, limits, mode) {
  if (identical(mode, "rescale")) {
    return(switch(coverage, ocean = 0.985, land = 0.015, both = 0.5))
  }
  bathy_rescale(0, limits)
}

bathy_rescale <- function(x, from) {
  (x - from[1]) / diff(from)
}

bathy_scale_rescaler <- function(coverage, reference_limits, mode) {
  if (identical(mode, "truncate")) {
    return(function(x, to = c(0, 1), from = reference_limits, ...) {
      bathy_squish(bathy_rescale(x, reference_limits), to)
    })
  }

  function(x, to = c(0, 1), from = range(x, na.rm = TRUE), ...) {
    bathy_rescale_coverage(x, from, coverage)
  }
}

bathy_rescale_coverage <- function(x, from, coverage) {
  from <- sort(from)
  if (
    !is.numeric(from) || length(from) != 2 || anyNA(from) || diff(from) == 0
  ) {
    return(bathy_squish(bathy_rescale(x, from)))
  }

  if (identical(coverage, "ocean")) {
    return(bathy_rescale_piecewise(x, from, zero = 0.985))
  }
  if (identical(coverage, "land")) {
    return(bathy_rescale_piecewise(x, from, zero = 0.015))
  }
  bathy_rescale_piecewise(x, from, zero = 0.5)
}

bathy_rescale_piecewise <- function(x, from, zero) {
  out <- numeric(length(x))
  has_ocean <- from[1] < 0
  has_land <- from[2] > 0

  if (has_ocean) {
    ocean <- x <= 0
    out[ocean] <- bathy_rescale_to(x[ocean], c(from[1], 0), c(0, zero))
  } else {
    ocean <- rep(FALSE, length(x))
  }

  if (has_land) {
    land <- x > 0
    out[land] <- bathy_rescale_to(x[land], c(0, from[2]), c(zero, 1))
  } else {
    land <- rep(FALSE, length(x))
  }

  if (!has_ocean || !has_land) {
    out <- bathy_rescale(x, from)
  }

  bathy_squish(out)
}

bathy_rescale_to <- function(x, from, to) {
  to[1] + bathy_rescale(x, from) * diff(to)
}

bathy_squish <- function(x, range = c(0, 1), ...) {
  pmin(pmax(x, range[1]), range[2])
}
