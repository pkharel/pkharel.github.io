+++
title = 'Migrating from Jekyll to Hugo'
date = 2024-10-10T18:26:54+05:45
tags = ['jekyll', 'hugo', 'github pages']
+++

## Jekyll
I've been using [Jekyll](https://jekyllrb.com/) to generate this site but it's
become increasingly frustrating to use mostly because of its dependency on
Ruby/bundle etc. I keep messing up my dev environment by accidentally installing
either a wrong version from a different source e.g Homebrew vs Ubuntu repository
or by installing bundles in the wrong location like system level instead of user
level.

## Hugo
[Hugo](https://gohugo.io/) seemed to promise a simpler and more streamlined
process of building and deploying which is why I wanted to test it out. Setting
up the build environment was super easy since I only had to install a single
binary.

## Migrating
After playing around with Hugo for a bit, I decided to migrate to it. Going over
the [Hugo quick start](https://gohugo.io/getting-started/quick-start/) first is
recommended.

First, I used the `hugo import` command.
```
hugo import <jekyll_dir> <new_hugo_dir>
```
After the command is done running, there will be instructions on adding a them
`ananke` and using it for your migrated site. However, I had issues with using
`ananke` and the `hugo server` command kept exiting and complaining about
template errors. I used the `archie` theme instead which worked without errors.

### URLs
By default, Jekyll page URLs look like `/year/month/day/page-title`. By default,
Hugo just uses the file name so the URL ends up looking like
`/post/filename.md`. To make the URLs match you need to add the following to the
`hugo.toml` file.
```
[permalinks]
  [permalinks.page]
    post = "/:year/:month/:day/:slug/"
```
After that, you need to add a `slug: ` line to all of your posts that match up
with the previous `page-title` that pointed to that page.

## GitHub Pages
GitHub Pages supports Hugo as well but the setup is slightly more complicated.
We need to define our own CI job to build the site. The [instructions on the
Hugo site](https://gohugo.io/hosting-and-deployment/hosting-on-github/) worked
for me without issues. I did have to change the branch name to match my
repository's default branch name.
