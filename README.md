# CompareFiles


## Overview

`CompareFiles` is a Dyalog APL user command that takes two files and feeds them to a comparison utility.

It comes with ready-to-use functions for a couple of popular comparison utilities:

* BeyondCompare
* CompareIt!
* KDiff3
* Meld
* UltraCompare

The comparison utilities are configured in "ini.json5".

Note that it is pretty easy to add more: enter

```
]CompareFiles -???
```

for details.

A different comparison utility of your choice can be configured in an INI file "user.json5".

If you work on Windows we recommend CompareIt!: it's fast and has a clean Interface.

Otherwise we recommend BeyondCompare: though its interface is way more complex, it is fast and is available on all major platforms.

However, both are not Open Source, but then they are reasonably priced.

`CompareFiles` comes with an API, meaning that other utilities can use it programmatically without going through Dyalog's user command framework.

In particular user commands like [`CompareThese`](https://github.com/aplteam/]CompareThese "Link to CompareThese on GitHub")
 and [`CompareWorkspaces`](https://github.com/aplteam/CompareWorkspaces) are using it.

### Three-file comparisons

Some utilities offer a three-file comparison. This is not supported by the user command. The reason is that this comes with distinct features/parameters that make it very hard to unify them under a single umbrella, not only in terms of implementation but also in using this feature.


## Prerequisites

* `CompareFiles` requires Dyalog Unicode 18.0 or better
* Link version 3.0.8 or better
* The [Tatin package manager](https://github.com/aplteam/tatin) must be available


## Installation

### Instructions

1. Download the latest release of `CompareFiles` from <https://github.com/aplteam/CompareFiles/releases>

2. Unzip the ZIP file you've downloaded into any empty folder you can write to; this folder can and should  be deleted after the installation.

   Now load the workspace `InstallCompareFiles`; `⎕LX` will make sure that any necessary steps are executed. Note that this is a safety measure against you loosing stuff in case you have already installed `CompareFiles` once and added a file "user.ini" and also functions for your favourite comparison utility: the workspace will take care of that.

Any newly started instance of Dyalog 18.0 or later will now come with the user command. 


### The API

The API is available only after executing the user command once; for that 

```
]CompareFiles '' ''
```

will suffice, although it will generate an error because no files were specified.

From now on `⎕SE.CompareFiles` hosts the public interface.

Alternatively you may load CompareFiles at a very early stage (but **after** Tatin was loaded!); this is strongly recommended in order to make the API available to other user commands.

You can achive this by adding the following function to `Setup.dyalog` in the `MyUCMDs/` folder:

```
∇  {r}←AutoloadCompareFiles dummy;res
   r←1
   '_CompareFiles'⎕SE.⎕NS''
   res←⎕SE.Link.Import ⎕SE._CompareFiles(GetMyUCMDsPath,'CompareFiles/APLSource')
   :If 'Imported: '{⍺≢(≢⍺)↑⍵}res
       ⎕←'Failed to load "CompareFiles" into ⎕SE...'
       r←0
   :Else
       ⎕SE._CompareFiles.Admin.EstablishAPI 1
       ⎕SE.CompareFiles←⎕SE._CompareFiles.API
       ⎕SE._CompareFiles.Init ⍬
   :EndIf
∇
```

This function needs `GetMyUCMDsPath`, so that needs to go into `Setup.dyalog` as well:

```
∇ r←GetMyUCMDsPath
  :If 'Win'≡3⍴1⊃# ⎕WG'APLVersion '
      r←(⊃⎕SH'ECHO %USERPROFILE%'),'\Documents\MyUCMDs\'
  :Else
      r←(⊃⎕SH'echo $HOME'),'/MyUCMDs/'
  :EndIf
∇
```


### Where is it installed?

`CompareFiles` will be installed into the folder `MyUCMDs/`

Where to find the `MyUCMDs/` folder depends on your operating system:

* Under Windows it is

  ``` 
  (2 ⎕nq # 'GetEnvironment' 'USERPROFILE'),'\Documents\MyUCMDs\'
  ```

* On non-Windows platforms it is `$HOME/MyUCMDs/`

Note that the `MyUCMDs/` folder is created by the Dyalog APL installer under Windows but not under Linux and Mac-OS. However, after loading `InstallCompareFiles` (end therefore implicitly running `⎕LX`) there will be a folder `MyUCMds/` on any platform.

Note that putting `CompareFiles` into `MyUCMDS/` has both advantages and disadvantages:

Advantages:

 * It will be available in all suitable versions of Dyalog APL installed on your machine
 * The user can modify and add files

Disadvantage:

 * It is a user-specific folder


### The INI file

The INI file comes with five pre-defined comparison utilities. If you are using one of them then you only have to make sure that the  path to that utility is available on the `PATH` environment variable, so that it can be found without knowing the installation folder.

Note that `CompareFiles` checks whether the utilities are actually both installed and available via `PATH`, and ignores those that are not. Therefore you don't need to remove utilities you have not installed.

The INI file uses these entries:


#### `EXEs`

A vector of text vectors with the actual names of the binaries. Used to actually start a utility.


#### `Names`

A vector of text vectors with alias names for the comparison utilities. These are used to communicate with the user (when presenting a list to choose from) and for specifying the `-use=` option of the user command `]CompareFiles`.

Note that comparisons are **not** case dependent.

#### `Default` 

By default the user is presented a list with all comparison utilities available. The one she chooses is remembered and used from then on. This is done by assigning it to `Default` in the INI file.

You may specify a different one by using the `-use=` option; this will overwrite the default.

At any point you can force the user command to give you again a list with all available utilities by specifying `-use=?`


### Adding a comparison utility

Adding a comparison utility is pretty easy; for details enter:

```
]CompareFiles -???
```