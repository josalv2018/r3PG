---
title: "r3PG-ReferenceManual"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{Title of your vignette}
  %\usepackage[UTF-8]{inputenc}
---



## Example


```r
out <- run_3PG(
  siteInputs = site_eum, 
  speciesInputs = species_eum, 
  forcingInputs = climate_eum, 
  managementInputs = NULL,
  parameterInputs = parameters_eum, 
  biasInputs = bias_eum,
  settings = list(light_model = 2, transp_model = 2, phys_model = 2, 
    correct_bias = 0, calculate_d13c = 0),
  df_out = FALSE)


out_long <- transf_out( out )
```