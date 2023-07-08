# CompareFiles


## Overview

`CompareFiles` is a Dyalog APL user command that takes two files and feeds them to a comparison utility.

It comes with ready-to-use functions for a couple of popular comparison utilities:

* BeyondCompare
* CompareIt!
* KDiff3
* Meld
* UltraCompare
* WinMerge

The comparison utilities are configured in "ini.json5".

Note that it is pretty easy to add more: enter

```
]CompareFiles -???
```

for details.

A different comparison utility of your choice can be configured in an INI file "user.json5".

If you work on Windows we recommend [WinMerge](https://winmerge.org/?lang=en "Link to the WinMerge homepage"): it's fast and has a clean Interface.

Otherwise we recommend [BeyondCompare](https://www.scootersoftware.com/ "Link to the BeyondCompare homepage"): though its interface is way more complex, it is fast and is available on all major platforms.

`WinMerge` is Open Source; BeyondCompare is not, but it is reasonably priced.

`CompareFiles` comes with an API, meaning that other utilities can use it programmatically without going through Dyalog's user command framework. For example, the user command 
[`APLGit2`](https://github.com/aplteam/APLGit2) is using it.

## Three-file comparisons

Some utilities offer a three-file comparison. This is not supported by the user command. The reason is that this comes with distinct features/parameters that make it very hard to unify them under a single umbrella, not only in terms of implementation but also in using this feature.


## Examples


```
]CompareFiles /path/to/file1 '/path/to/file 1'
]CompareFiles /path/to/file1 '/path/to/file 1' -use=WinMerge
]CompareFiles /path/to/file1 '/path/to/file 1' -use=WinMerge -save
]CompareFiles /path/to/file1 '/path/to/file 1' -use=?
]CompareFiles /path/to/file1 '/path/to/file 1' -caption1-Left -caption2-'Right side'
]CompareFiles /path/to/file1 '/path/to/file 1' -edit1 -edit2
```


## Prerequisites

* `CompareFiles` requires Dyalog Unicode 18.0 or better
* Link version 3.0.8 or better
* The [Tatin package manager](https://github.com/aplteam/tatin) must be available


## Installation

Execute this and you are done:

```
]Tatin.InstallPackages [tatin]comparefiles [myucmds]
```

Any newly started instance of Dyalog 18.0 or later will now come with the user command. In an already running instance executing `]ureset` will do.

This will make `]CompareFiles` available, but it will not establish the API. However, executing `]CompareFiles -version` will force it to load the API into `⎕SE`.

If you want the API to be available right from the start then please consult the article [Dyalog User Commands](https://aplwiki.com/wiki/Dyalog_User_Commands "Link to the APL wiki").

## How to use the API

First ask for a parameter space for the comparison utility you are going to use. For example, assuming that you want to use `WinMerge`:

```
      p←⎕SE.CompareFiles.ComparisonTools.CreateParmsForWinMerge
      p.file1←'/path/to/file1'
      p.file1←'/path/to/file2'     
      ⎕SE.CompareFiles.ComparisonTools.WinMerge p
```

If you want captions that are different from the filenames then set `caption1` and `caption2` accordingly.

If you want to be able to edit the files from within `WinMerge` set `edit1` and/or `edit2` accordingly.


## The INI file

The INI file comes with several pre-defined comparison utilities. If you are using one of them then you only have to make sure that the  path to that utility is available on the `PATH` environment variable, so that it can be found without knowing the installation folder.

Note that `CompareFiles` checks whether the utilities are actually both installed and available via `PATH`, and ignores those that are not. Therefore you don't need to remove utilities you have not installed.

The INI file can be found in the folder that is returned by `⎕se.CompareFiles.GetPathToINI`.

It uses these entries:


### `EXEs`

A vector of text vectors with the actual names of the binaries; no path, `CompareFiles` relies on the environment variable `PATH`. This is used to actually start a utility.


### `Names`

A vector of text vectors with alias names for the comparison utilities. These are used to communicate with the user (when presenting a list to choose from) and for specifying the `-use=` modifier of the user command `]CompareFiles`.

Note that comparisons for alias names of comparison utilities are **not** case dependent.

### `Default` 

By default the user is presented a list of all comparison utilities available. The one she chooses is remembered and used from then on. This is done by assigning it to `Default` in the INI file.

You may specify a different one by using the `-use=` option; however, this will **not** overwrite the default: for that you must specify the `-save` modifier.

At any point you can force the user command to give you again a list with all available utilities by specifying `-use=?`


## Adding a comparison utility

Adding a comparison utility is pretty easy; for details enter:

```
]CompareFiles -???
```