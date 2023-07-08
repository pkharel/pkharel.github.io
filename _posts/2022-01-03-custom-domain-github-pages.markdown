---
layout: post 
title:  "Custom domain for GitHub Pages"
tags: github pages custom domain
---

Documenting the steps I took to use a self owned domain for GitHub Pages

# DNS configuration

* Create type A records for the [IP addresses from GitHub](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#about-custom-domain-configuration)
* Create CNAME record for GitHub Pages site e.g `pkharel.github.io`

# GitHub Pages configuration

* Create a Github Pages repository
* Go to `Repository Settings -> Pages -> Custom domain` and add your domain
