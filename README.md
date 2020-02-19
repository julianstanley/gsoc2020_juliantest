Tests for GSOC 2020 - Constrained Changepoint GUI
================
Julian Stanley
February-March 2020

<img align="right" height="225" src="./README_files/logo.png">

# Overview

This repository and this accompanying README is a set of tests for
Google Summer of Code (GSOC) 2020.

These tests serve to show that I have the basic competencies required to
make a GUI for the [gfpop package](https://github.com/vrunge/gfpop),
which detects changepoints in univariate time series constrained to a
graph structure.

# Easy Test

This test requires that I download the gfpop package, run the code in
the vignette, change the penalty parameter, and make a multi-panel
ggplot that shows how the model changes as the penalty parameter is
varied. It specifies that there should be one panel for each penalty
parameter value.

*todo*

# Medium Test

This test requires that I make a shiny app with an input that allows the
user to select the penalty parameter in that dataset, and shows a ggplot
of the data and model with that penalty parameter.

*todo*

# Hard Test

For this test, I will write a D3.js data visualization in which the user
can hover over one displayed item and see it highlighted, along with
other items.

*todo*
