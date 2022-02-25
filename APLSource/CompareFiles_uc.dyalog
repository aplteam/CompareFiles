:Class  CompareFiles_uc
⍝ User Command script for "CompareFiles".
⍝ Expects the WS CompareFiles.dws to be a sibling of this script.
⍝ Kai Jaeger - APL Team Ltd
⍝ Version 2.0.0 from 2022-02-21

    ⎕IO←⎕ML←1

    ∇ r←List;res;⎕TRAP
      :Access Shared Public
      ⍝⎕TRAP←0'S'
      ⍝∘∘∘
      r←⎕NS''
      r.Group←'TOOLS'
      r.Name←'CompareFiles'
      r.Parse←'3s -edit -edit1 -edit2 -edit3 -caption1= -caption2= -caption3= -use='
      r.Desc←'Compare two files with each other.'
      :If 0=⎕SE.⎕NC'_CompareFiles'
          ⎕SE.⎕EX'CompareFiles'
          {⍵ ⎕SE.⎕NS''}¨'_CompareFiles' 'CompareFiles'
          res←⎕SE.Link.Import ⎕SE._CompareFiles(GetMyUCMDsPath,'CompareFiles/APLSource')
          :If 'Imported: '{⍺≢(≢⍺)↑⍵}res
              ⎕←'Failed to load "CompareFiles" into ⎕SE...'
          :EndIf
      :EndIf
      ⍝Done
    ∇

    ∇ r←Run(Cmd Args);fn1;fn2;fn3;parms;stdOut;rc;stdErr;orig1;orig2;orig3;exe;name
      :Access Shared Public
      C←⎕SE._CompareFiles
      CT←C.ComparisonTools
      C.Init ⍬
      (exe name)←C.EstablishCompareEXE{0≡⍵:'' ⋄ ⍵}Args.use
      →(0=≢exe)/0
      :Trap 6
          parms←CT.⍎'CreateParmsFor',name
      :Else
          →0⊣⎕←'Missing: function "CreateParmsFor',name,'"'
      :EndTrap
      :If ≡/LowercaseIfWindows¨Args._1 Args._2
          'You cannot compare a file with itself'⎕SIGNAL 911
      :EndIf
      parms.use←exe
      parms.name←name
      parms.file1←'Please select first filename'GetFilename Args._1
      →(0=≢parms.file1)/0
      parms.file2←'Please select second filename'GetFilename Args._2
      →(0=≢parms.file2)/0
      parms.file3←{0≡⍵:'' ⋄ ⍵}Args._3
      parms.(file1 file2)←{'expand'C.##.FilesAndDirs.NormalizePath ⍵}¨parms.(file1 file2)
      parms.(caption1 caption2 caption3)←parms.(file1 file2 file3){0≡⍵:⍺ ⋄ ⍵}¨Args.(caption1 caption2 caption3)
      (orig1 orig2)←ReadFile¨parms.(file1 file2)
      :If 0<≢parms.file3
          :If 0≢parms.file3
              parms.file3←'expand'C.##.FilesAndDirs.NormalizePath parms.file3
              orig3←ReadFile parms.file3
          :Else
              parms.file3←''
          :EndIf
      :EndIf
      :If Args.edit
          parms.(edit1 edit2 edit3)←parms.edit←1
      :Else
          parms.(edit1 edit2 edit3)←Args.(edit1 edit2 edit3)
      :EndIf
      (rc stdOut stdErr)←C.Compare parms
      :If 0≠rc
          ⎕EM ⎕SIGNAL 11
      :EndIf
      r←(2+(0<≢parms.file3)∧(,0)≢,parms.file3)⍴0
      :If 0<≢parms.file1
      :AndIf parms.edit1
          r[1]←orig1≢ReadFile parms.file1
      :EndIf
      :If 0<≢parms.file2
      :AndIf parms.edit2
          r[2]←orig2≢ReadFile parms.file2
      :EndIf
      :If 0<≢parms.file3
      :AndIf parms.edit3
          r[3]←orig3≢ReadFile parms.file3
      :EndIf
    ∇

    ∇ r←level Help Cmd
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          r,←⊂List.Desc
      :Case 1
          r,←⊂'Specify two or three filenames as arguments. If you do not specify any, or just one'
          r,←⊂'filename, then under the Windows operating system a Browse window is opened which you '
          r,←⊂'can use to specify the missing file(s). Note that some utilities do not support'
          r,←⊂'three-file comparisons.'
          r,←⊂''
          r,←⊂'The files can then be compared with one of the compare utilities defined in "ini.json5"'
          r,←⊂'and potentially also "user.json5" - see below.'
          r,←⊂''          
          r,←⊂'Naturally utilities that are not available are ignored, and the user might select one'
          r,←⊂'from the remaining list if there are more than just one left.'          
          r,←⊂'Instead you may specify a comparison utility with -use= by assigning the name as'
          r,←⊂'defined in the "ini.jsn5" file. Either way, your choice will be remembered.'
          r,←⊂''
          r,←⊂'By default no file can be edited, but you can change this by specifying either -edit,'
          r,←⊂'allowing all files to be edited, or one of -edit1, -edit2 or -edit3, allowing just the'
          r,←⊂'corresponding file to be edited. Of course this is true only if the chosen comparison'
          r,←⊂'utility is supporting this: some do not support read-only, some do not allow editing.'
          r,←⊂''
          r,←⊂'-caption[123] can be set as caption for the comparison panes. Might have no effect in'
          r,←⊂'case the chosen comparison tool does not support something like this. Defaults to the'
          r,←⊂'name of the files.'
          r,←⊂''
          r,←⊂'The command returns a vector of 2 or 3 Booleans, depending in the number of files. '
          r,←⊂'A 1 indicates that the associated file has been changed.'
          r,←⊂''
          r,←⊂'Note that you can add yoiur favourite comparison utility; enter:'
          r,←⊂']CompareFiles -???'
          r,←⊂'for how to do that,'
      :Case 2
          r,←⊂'In order to add your favourite comparison utility follow this recipe:'
          r,←⊂''
          r,←⊂' 1. Add a file "user.json5" to MyUCMDs\CompareFiles'
          r,←⊂' 2. Edit the file and add your favourite utility. View "ini.json5" as a reference.'
          r,←⊂' 3. For a utility "Foo" add a fn Foo to MyUCMDs/CompareFiles/ComparisonTools/'
          r,←⊂' 4. Add also a function CreateParmsForFoo to MyUCMDs/CompareFiles/ComparisonTools/'
          r,←⊂'    Copy existing fns by renaming and amending them.'
          r,←⊂''
          r,←⊂'Notes:'
          r,←⊂' * Adding an entry to "ini.json5" would work, but will be overwritten in case of an update'
          r,←⊂' * You may copy an already existing fn for both the comparison and the parameter space'
      :EndSelect
      r,←(level=0)/⊂']',Cmd,' -??  ⍝ for syntax details'
    ∇

    ∇ r←GetMyUCMDsPath
      :If 'Win'≡3⍴1⊃# ⎕WG'APLVersion '
          r←(⊃⎕SH'ECHO %USERPROFILE%'),'\Documents\MyUCMDs\'
      :Else
          r←(⊃⎕SH'echo $HOME'),'/MyUCMDs/'
      :EndIf
    ∇

    ∇ index←{manyFlag}Select options;flag;answer;question;value;bool
    ⍝ Presents `options` as a numbered list and allows the user to select either exactly one or multiple ones.\\
    ⍝ One is the default.\\
    ⍝ `manyFlag` default to 0 (meaning just one item might be selected) or 1, in which case
    ⍝ multiple items can be specified.
    ⍝ `options` must not have more than 999 items.
    ⍝ If the user aborts `index` is `⍬`.
      manyFlag←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'manyFlag'
      'Invalid right argument; must be a vector of text vectors.'⎕SIGNAL 11/⍨2≠≡options
      'Right argument has more than 999 items'⎕SIGNAL 11/⍨999<≢options
      flag←0
      :Repeat
          ⎕←(⎕PW-1)⍴'-'
          ⎕←⍪{((⊂'. '),¨⍨(⊂3 0)⍕¨⍳⍴⍵),¨⍵}options
          ⎕←''
          :If 0<≢answer←⍞,0/⍞←question←'Select one ',(manyFlag/'or more '),'item',((manyFlag)/'s'),' (q=quit',(manyFlag/', a=all'),') : '
              answer←(⍴question)↓answer
              :If 1=≢answer
              :AndIf answer∊'Qq',manyFlag/'Aa'
                  :If answer∊'Qq'
                      index←⍬
                      :Return
                  :Else
                      index←⍳≢options
                      flag←1
                  :EndIf
              :Else
                  (bool value)←⎕VFI answer
                  :If ∧/bool
                  :AndIf manyFlag∨1=+/bool
                      value←bool/value
                  :AndIf ∧/value∊⍳⍴options
                      index←value
                      flag←1
                  :EndIf
              :EndIf
          :EndIf
      :Until flag
      index←{1<≢⍵:⍵ ⋄ ⊃⍵}index
      ⍝Done
    ∇

    ∇ filename←caption GetFilename filename;bb;flag;msgb;res
      :If 0=≢filename
      :OrIf (,0)≡,filename
      :OrIf 0=C.##.FilesAndDirs.IsFile filename
          'bb'⎕WC'BrowseBox'('Caption'caption)('HasEdit' 1)('BrowseFor' 'File')('Target' '')('Event'('FileBoxOK' 'FileBoxCancel')1)
          flag←0
          :Repeat
              res←⎕DQ'bb'
              :If 'FileBoxCancel'≡2⊃res
                  filename←''
                  :Return
              :EndIf
              :If 0=flag←C.##.FilesAndDirs.IsFile filename←bb.Target
                  'msgb'⎕WC'MsgBox'('Caption' 'File selection for "CompareFiles"')('Style' 'Info')('Text'('This:'filename'is not a file - try again'))
                  ⎕DQ'msgb'
              :EndIf
          :Until flag
      :EndIf
      ⍝Done
    ∇

    ∇ r←ReadFile filename
      :Trap 11
          r←⊃⎕NGET filename
      :Case 11
          ('Could not read file ',filename)⎕SIGNAL 11
      :EndTrap
    ∇

    ∇ txt←LowercaseIfWindows txt
      :If 'Win'≡C.##.APLTreeUtils2.GetOperatingSystem ⍬
          txt←⎕C txt
      :EndIf
    ∇

:EndClass
