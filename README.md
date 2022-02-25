# CompareFiles


## Overview

`CompareFiles` is a Dyalog APL user command that takes two or three files and feeds them to a comparison utility.

The comparison utility of your choice can be configured in an INI file ("ini.json5").

It comes with ready-to-use functions for a couple of popular comparison utilities:

* BeyondCompare
* CompareIt!
* KDiff3
* Meld
* UltraCompare

Note that it is pretty easy to add more.

If you work on Windows we recommend CompareIt!: it's fast and has the best Interface, but be aware that it does not have three-file comparison and is Windows-only.

Otherwise we recommend BeyondCompare: it is available on all major platforms and offers important features: 

* Support for Git
* Optionally 3-file comparison
* Both edit and read-only mode for every file independently

However, both are not Open Source, but then they are reasonably priced.

`CompareFiles` comes with an API, meaning that other tools can use it programmatically without going through Dyalog's user command framework.


## Prerequisites

* `CompareFiles` requires Dyalog Unicode 18.0 or better
* Link version 3.0.8 or better
* The [Tatin package manager](https://github.com/aplteam/tatin) must be available


## Installation

### Instructions

1. Download the latest release of `CompareFiles` from <https://github.com/aplteam/CompareFiles/releases>

2. Unzip the ZIP file you've downloaded into any empty folder you can write to; this folder can and should  be deleted after the installation.

   Now load the workspace `InstallCompareFiles`; `⎕LX` will make sure that any necessary steps are executed. Note that this is a safety measure against you loosing stuff in case you have already installed `CompareFiles` once and added a file "user.ini" and added functions for your favourite comparison utility: the workspace will take care of that.

Any newly started instance of Dyalog 18.0 or later will now come with the user command

```
]CompareFiles
```

The API will be available in `⎕SE.CompareFiles` once you start Dyalog APL.

### Where is it installed?

`CompareFiles` will be installed into folder `MyUCMDs/`.

Where to find the `MyUCMDs/` folder depends on your operating system:

* Under Windows it is

  ``` 
  (2 ⎕nq # 'GetEnvironment' 'USERPROFILE'),'\Documents\MyUCMDs\'
  ```

* On non-Windows platforms it is `$HOME/MyUCMDs/`

Note that the `MyUCMDs/` folder is created by the Dyalog APL installer under Windows but not under Linux and Mac-OS, so you need to create the folder yourself on non-Windows platforms. However, after loading `InstallCompareFiles` (end therefore implicitly running `⎕LX`) there will be a folder `MyUCMds/` on any platform.

Note that putting `CompareFiles` into `MyUCMDS/` has both advantages and disadvantages:

* Advantages 

  * It will be available in all suitable versions of Dyalog APL installed on your machine
  * The user can modify and add files

* Disadvantage

  * It is a user-specific folder


### The INI file

The INI file comes with five pre-defined comparison utilities. If you are using one of them then you only have to make sure that the  path to that utility in on the `PATH` environment variable so that it can be found without knowing the installation folder.

Note that `CompareFiles` checks whether the utilities are actually installed, and ignores those that are not. Therefore you don't need to remove utilities you are not using.

The INI file uses these entries:


#### `EXEs`

A vector of text vectors with the actual names of the comparison utilities. Used to actually start a utility.


#### `Names`

A vector of text vectors with alias names for the comparison utilities. These are used to communicate with the user (when presenting a list to choose from) and for specifying the `-use=` option of the user command `]CompareFiles`.

Note that comparisons are **not** case dependent.

#### `Default` 

By default the user is presented a list with all comparison utilities available. The one she chooses is remembered and used from then on.

You may specify a different one by using the `-use=` option; this will overwrite the default.

At any point you can force the user command to give you again a list with all available utilities by specifying `-use=?`


### Adding a comparison utility

Adding a comparison utility is pretty easy; for details enter:

```
]CompareFiles -???
```