# mediaframe

A Flutter media frame Android application to show a slideshow of pictures and videos.
I'm not aware of any reason iOS couldn't easily be supported but my use case was
Android so I didn't spend any time setting up iOS.

## Motivation

I wanted a digital picture frame that supports both pictures and videos and supports
switching to a clock display at night.  In addition, with little kids in the house I
wanted the slideshow to pause periodically and switch to displaying the clock so the
kids wouldn't sit and stare at the screen all day.

Since I didn't find anything that obviously supported everything I wanted, I decided
to try out Vue Native and Flutter.  I ultimately settled on using Flutter because
I liked the way the framework worked and it felt like it is well thought out.

## Features

* Displays a slideshow of pictures and videos
* Periodically switches to clock display
* Clock display includes current weather (requires OpenWeatherMap.org API key)
* Night mode switches to clock display
* Unlock code optionally protects settings and dismissing of the clock screen

## Getting Started

For help getting started with Flutter, view
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
