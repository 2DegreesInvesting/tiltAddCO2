
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tiltAddCO2

<!-- badges: start -->

[![R-CMD-check](https://github.com/2DegreesInvesting/tiltAddCO2/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/2DegreesInvesting/tiltAddCO2/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of tiltAddCO2 is to add CO2 data to tilt profiles.

## Example

``` r
library(dplyr, warn.conflicts = FALSE)
library(readr)
library(tiltToyData)
library(tiltIndicatorAfter)
library(tiltAddCO2)

file <- toy_emissions_profile_products_ecoinvent()
co2 <- read_csv(file, show_col_types = FALSE)
profile <- toy_profile_emissions_impl_output()

with_co2 <- profile |>
  add_co2(co2)

with_co2 |>
  unnest_product() |>
  relocate(matches("co2"))
#> # A tibble: 456 × 28
#>    co2_footprint companies_id    company_name country emission_profile benchmark
#>            <dbl> <chr>           <chr>        <chr>   <chr>            <chr>    
#>  1          303. asteria_megalo… asteria_meg… austria high             all      
#>  2          303. asteria_megalo… asteria_meg… austria high             isic_4di…
#>  3          303. asteria_megalo… asteria_meg… austria high             tilt_sec…
#>  4          303. asteria_megalo… asteria_meg… austria high             unit     
#>  5          303. asteria_megalo… asteria_meg… austria high             unit_isi…
#>  6          303. asteria_megalo… asteria_meg… austria high             unit_til…
#>  7          303. skarn_gallinule skarn_galli… austria high             all      
#>  8          303. skarn_gallinule skarn_galli… austria high             isic_4di…
#>  9          303. skarn_gallinule skarn_galli… austria high             tilt_sec…
#> 10          303. skarn_gallinule skarn_galli… austria high             unit     
#> # ℹ 446 more rows
#> # ℹ 22 more variables: ep_product <chr>, matched_activity_name <chr>,
#> #   matched_reference_product <chr>, unit <chr>, multi_match <lgl>,
#> #   matching_certainty <chr>, matching_certainty_company_average <chr>,
#> #   tilt_sector <chr>, tilt_subsector <chr>, isic_4digit <chr>,
#> #   isic_4digit_name <chr>, company_city <chr>, postcode <chr>, address <chr>,
#> #   main_activity <chr>, activity_uuid_product_uuid <chr>, …

with_co2 |>
  unnest_company() |>
  relocate(matches("co2"))
#> # A tibble: 1,728 × 13
#>    co2_avg companies_id              company_name country emission_profile_share
#>      <dbl> <chr>                     <chr>        <chr>                    <dbl>
#>  1    303. asteria_megalotomusquinq… asteria_meg… austria                      1
#>  2    303. asteria_megalotomusquinq… asteria_meg… austria                      0
#>  3    303. asteria_megalotomusquinq… asteria_meg… austria                      0
#>  4    303. asteria_megalotomusquinq… asteria_meg… austria                      0
#>  5    303. asteria_megalotomusquinq… asteria_meg… austria                      1
#>  6    303. asteria_megalotomusquinq… asteria_meg… austria                      0
#>  7    303. asteria_megalotomusquinq… asteria_meg… austria                      0
#>  8    303. asteria_megalotomusquinq… asteria_meg… austria                      0
#>  9    303. asteria_megalotomusquinq… asteria_meg… austria                      1
#> 10    303. asteria_megalotomusquinq… asteria_meg… austria                      0
#> # ℹ 1,718 more rows
#> # ℹ 8 more variables: emission_profile <chr>, benchmark <chr>,
#> #   matching_certainty_company_average <chr>, company_city <chr>,
#> #   postcode <chr>, address <chr>, main_activity <chr>,
#> #   profile_ranking_avg <dbl>
```
