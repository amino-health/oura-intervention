# Oura Intervention

## About the project

## Built with

## Getting started

### Prerequisites

- Flutter

### Installation

https://docs.flutter.dev/get-started/install

## Usage

### Run application

If using Microsoft Edge, run:

```cmd
Flutter run -d edge --web-port 8080
```

If using Google Chrome, web security must be disabled according to the following steps:

----------------------------------------------------------------------------------------------------------------------------------
1. Close all instances of Chrome
2. Remove flutter_tools.stamp from flutter\bin\cache
3. Open chrome.dart from flutter\packages\flutter_tools\lib\src\web and on line 205 (under '--disable-extensions'), add the line '--disable-web-security'
----------------------------------------------------------------------------------------------------------------------------------

After said steps are finished, run:

```cmd
run
```

### Test widgets

For debugging widgets, add the widget to the widgetList variable in lib/misc/TestWidgets.dart and run:

```cmd
Flutter run -t lib/misc/TestWidgets.dart
```
