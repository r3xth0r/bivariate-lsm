# Communicating uncertainties in landslide susceptibility modeling using bivariate mapping

<p align="center">
    <a href="https://style.tidyverse.org">
        <img alt="Code style: tidyverse" src="https://img.shields.io/badge/codestyle-tidyverse-blue"></a>
    <a href="https://github.com/psf/black">
        <img alt="Code style: black" src="https://img.shields.io/badge/codestyle-black-000000.svg"></a>
</p>

This repository supplements the manuscript by
Matthias Schlögl<sup>[![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0002-4357-523X)</sup>,
Anita Graser<sup>[![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0001-5361-2885)</sup>,
Stefan Steger<sup>[![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0003-0886-5191)</sup>,
Jasmin Lampert<sup>[![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0002-0414-4525)</sup> and
Raphael Spiekermann<sup>[![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0002-4772-9750)</sup>
(2024):
**Brief communication: Visualizing uncertainties in landslide susceptibility modeling using bivariate mapping**.
*Nat. Hazards Earth Syst. Sci. Discuss.* [preprint]. [doi:10.5194/nhess-2024-213](https://doi.org/10.5194/nhess-2024-213).

## Repo structure 

The general repo structure is as follows:
- `dat`: data sets
- `doc`: documentation
- `gis`: QGIS files
- `plt`: plots / figures
- `public`: rayshader output
- `R`: custom R source code (functions)
- `renv`: R environment configuration - see [renv](https://rstudio.github.io/renv/articles/renv.html)
- `src`: development (scripts)

## Data

This repository contains sample data for plotting. If you have [Git LFS](https://git-lfs.com/) installed, you can simply clone the full repo using `git clone`. If not, download and install the Git LFS extension and update the cloned repository with `git lfs fetch --all` and `git lfs pull`.
