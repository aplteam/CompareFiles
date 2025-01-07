# CompareFiles



## Overview

`CompareFiles` takes two files and feeds them to a comparison utility. It's an attempt to standardize the interface to comparison utilities across Windows, Linux and Mac OS.

It it available in two ways:

* As a user command 
* As an API that can be used by other utilties and user commands

  For example, the user command `]APLGits` uses the API when the command `]APLGit2.CompareCommits` is issued.

It comes with ready-to-use functions for a couple of popular comparison utilities:

* BeyondCompare
* CompareIt!
* Meld
* WinMerge

The comparison utilities are configured in `comparefiles-ini.json5` which is copied into a folder in the user's home folder:

```
.config/dyalog/compareFiles/
```

It is pretty easy to add more: enter

```
]CompareFiles -???
```

for details.

With version 5 the name of the ini file was changed from `ini.json5` to `comparefiles-ini.json5`. The location of the INI file was changed as well: from a folder `aplteam/CompareFiles` in either `%APPDATA%` on Windows or `/Applications/mdyalog/` on Linux or `/Applications/Dyalog` on Mac OS to `.config/dyalog/aplteam/CompareFilescomparefiles-ini.json5` in the user's home folder.


## How to start

### Installation

For version 18.0, 18.2 and 19.0 install `CompareFiles` into `[MyUCMDs]`:

```
]InstallPackage [tatin]CompareFiles [MyUCMDs]
```

### Which one?!

If you work on Windows we recommend [WinMerge](https://winmerge.org/?lang=en "Link to the WinMerge homepage"): it's fast and has a clean Interface.

Otherwise we recommend [BeyondCompare](https://www.scootersoftware.com/ "Link to the BeyondCompare homepage"): though its interface is way more complex, it is fast and is available on all major platforms.

`WinMerge` is Open Source; BeyondCompare is not, but it is reasonably priced.


## Three-file comparisons

Some utilities offer a three-file comparison. This is not supported by `CompareFiles`. The reason is that this comes with distinct features/parameters that make it very hard to unify them under a single umbrella, not only in terms of implementation but also in using this feature.


## Examples


```
]CompareFiles /path/to/file1 '/path/to/file 1'
]CompareFiles /path/to/file1 '/path/to/file 1' -use=WinMerge
]CompareFiles /path/to/file1 '/path/to/file 1' -use=WinMerge -save
]CompareFiles /path/to/file1 '/path/to/file 1' -use=?
]CompareFiles /path/to/file1 '/path/to/file 1' -caption1-Left -caption2-'Right side'
]CompareFiles /path/to/file1 '/path/to/file 1' -edit1 -edit2
```

## Operatings systems

`]CompareFiles` attempts to work on Windows, Linux and Mac-OS. Because not all comparison utilities work on all platforms the configuration file has three sections for "Win", "Lin" and "Mac". If a comparison utility happens to work on all three platforms you must add it to all those sections.

You can specify a default comparison utility 

## Prerequisites

* `CompareFiles` requires Dyalog Unicode 18.0 or better
* Link version 3.0.8 or better
* The [Tatin package manager](https://github.com/aplteam/tatin) must be available
* The comparison utility you want to use must be added to the configuration file in one of two possible ways:

  * The full path pointing to the executable
  * Just the name of the execuatable

    This works only if the path of the folder where the executable lives was added to the operating system's `PATH` variable.


## Installation

Execute this and you are done:

```
]Tatin.InstallPackages [tatin]comparefiles [myucmds]
```

Any newly started instance of Dyalog 18.0 or later will now come with the user command. In an already running instance executing `]ureset` will do.

However, although this will make the `]CompareFiles` user command available, it will not establish the API in `⎕SE`, but executing `]CompareFiles -version` (or any other sub command) will enforce this.

If you want the API to be available right from the start, which is recommended, then please consult the article [Dyalog User Commands](https://aplwiki.com/wiki/Dyalog_User_Commands "Link to the APL wiki").

## How to use the API

First ask for a parameter space for the comparison utility you are going to use. For example, assuming that you want to use `WinMerge`:

```
p←⎕SE.CompareFiles.ComparisonTools.CreateParmsForWinMerge
p.file1←'/path/to/file1'
p.file1←'/path/to/file2'     
⎕SE.CompareFiles.ComparisonTools.WinMerge p
```

If you want captions that are different from the filenames then set `p.caption1` and `p.caption2` accordingly.

If you want to be able to edit the files from within `WinMerge` set `p.edit1` and/or `p.edit2` accordingly.


## The configuration file

The configuration file comes with several pre-defined comparison utilities. If you are using one of them then you only have to make sure that the path to that utility is available on the `PATH` environment variable, so that it can be found without knowing the installation folder.

Alternatively you can specify the full path to the executable in the configuration file.
However, make sure that use either use `/` as folder separator or double the backslashes: `\\`.

Note that `CompareFiles` checks whether the utilities are actually available, and ignores those that are not. Therefore you don't need to remove utilities you have not installed.

The configuration file can be found in the folder that is returned by `⎕se.CompareFiles.GetPathToConfig`.

It uses these entries:


### `EXEs`

A vector of text vectors with the actual names of the binaries; no path, `CompareFiles` relies on the environment variable `PATH`. This is used to actually start a utility.


### `Names`

A vector of text vectors with alias names for the comparison utilities. These are used to communicate with the user (when presenting a list to choose from) and for specifying the `-use=` modifier of the user command `]CompareFiles`.

Note that comparisons for alias names of comparison utilities are **not** case dependent.

### `Default` 

By default the user is presented a list of all comparison utilities available. The one she chooses is remembered and used from then on. This is done by assigning it to `Default` in the configuration file.

You may specify a different one by using the `-use=` option; however, this will **not** overwrite the default: for that you must specify the `-save` modifier.

At any point you can force the user command to give you again a list with all available utilities by specifying `-use=?`


## Adding a comparison utility

Adding a comparison utility is pretty easy; for details enter:

```
]CompareFiles -???
```



## Other Comparison Utilities

### KDiff3

The project has been abandoned for many years. 

The required functions remain available, but since a bug on Mac OS was discovered (KDiff3 cannot deal with filenames with a space in it on Mac OS) the KDiff3-specific test cases were deactivated, and it's not supported "offically" anymore.

### UltraCompare

Requires a payed license. When the trial period expired I asked them for a free license and did not get one.

The required functions remain available, but the UltraCompare-specific test cases were removed, and it's not supported "offically" anymore.


