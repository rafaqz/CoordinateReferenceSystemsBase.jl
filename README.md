# GeoFormatTypes

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/dev)
[![Build Status](https://travis-ci.org/JuliaGeo/GeoFormatTypes.jl.svg?branch=master)](https://travis-ci.org/JuliaGeo/GeoFormatTypes.jl)


GeoFormatTypes defines wrapper types to make it easy to pass Geographic formats like WellKnownText or GeoJSON between packages while keeping information about what format is contained - instead of passing a `String` or `Int` that could be from any type.

Wrapper types also allow methods such as `convert` to work with data in
multiple formats, instead of defining lists of format-specific handling methods.