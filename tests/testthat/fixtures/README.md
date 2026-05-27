# Test fixtures

This directory contains small local files used by tests that must not depend on
external services.

Planned fixtures:

- `gebco-small.nc`: a minimal NetCDF grid with `lon`, `lat`, and `elevation`
  variables, used to test GEBCO parsing without calling the GEBCO API.
- `noaa-small.tif`: a minimal raster response, used to test NOAA raster parsing
  without calling the NOAA service.
- small CSV/XYZ files for `read_bathy()` and cache-loading tests.

Rules:

- keep fixtures small;
- do not store downloaded full-resolution bathymetry;
- do not require network access in tests;
- use `testthat::test_path("fixtures", ...)` to locate files.
