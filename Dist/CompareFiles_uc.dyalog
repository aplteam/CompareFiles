:Class  CompareFiles
⍝ User Command script for "CompareFiles".
⍝ Expects the WS CompareFiles.dws to be a sibling of this script.
⍝ Kai Jaeger - APL Team Ltd
⍝ Version 1.0.0 - 2019-02-21

    ⎕IO←⎕ML←1

    ∇ r←List
      :Access Shared Public
      r←⎕NS''
      r.Group←'TOOLS'
      r.Name←'CompareFiles'
      r.Parse←'2s -exe= -ro1∊01 -ro2∊01 -label1= -label2='
      r.Desc←'Compare two files with each other.'
    ∇

    ∇ r←Run(Cmd Args);C;EXE;NAME;file1;file2;origFile1;origFile2
      :Access Shared Public
      r←0 0
     
      ⍝ We now create a namespace ⎕SE.CompareFiles but keep it local to this function!
      ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
      ⍝ This code CANNOT run in a sub-function!
      ⎕SE.⎕SHADOW'CompareFiles'
      ⎕SE.⎕EX'CompareFiles'
      'CompareFiles'⎕SE.⎕NS''
      ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
     
      LoadCompareFiles ##.SourceFile
      C←⎕SE.CompareFiles.CompareFiles
      C.Init ##.SourceFile C
      (EXE NAME)←EstablishExeAndName C Args
      →(⍬ ⍬≡EXE NAME)/0
      Args._1←'Please select first filename'GetFilename Args._1
      →(0=≢Args._1)/0
      Args._2←'Please select second filename'GetFilename Args._2
      →(0=≢Args._2)/0
      (Args._1 Args._2)←{'expand'C.##.FilesAndDirs.NormalizePath ⍵}¨Args._1 Args._2
      origFile1←C.##.APLTreeUtils.ReadUtf8File Args._1
      origFile2←C.##.APLTreeUtils.ReadUtf8File Args._2
      :Select C.##.APLTreeUtils.Lowercase NAME
      :Case 'kdiff3'
          KDiff3 C EXE NAME Args
      :Case 'beyondcompare'
          BeyondCompare C EXE NAME Args
      :Case 'compareit'
          CompareIt C EXE NAME Args
      :Case 'meld'
          Meld C EXE NAME Args
      :Case 'ultracompare'
          UltraCompare C EXE NAME Args
      :Else
          6 ⎕SIGNAL⍨'Comparison tool "',NAME,'" not found!'
      :EndSelect
      :If ~(⊂NAME)∊,⊂'KDiff3'
          file1←C.##.APLTreeUtils.ReadUtf8File Args._1
          file2←C.##.APLTreeUtils.ReadUtf8File Args._2
          r←(origFile1≢file1)(origFile2≢file2)
      :EndIf
      ⍝Done
    ∇

    ∇ r←level Help Cmd
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          r,←⊂List.Desc
      :Case 1
          r,←⊂'Specify up to two filenames as arguments. If you do not specify any or just one filename a Browse'
          r,←⊂'window is opened which you can use to specify the missing file(s).'
          r,←⊂''
          r,←⊂'The specified files can then be compared, by default with the compare utility specified in the INI file.'
          r,←⊂'You may overwrite the INI file default by specifying, say, -exe=/pathToExe/compareutil.exe'
          r,←⊂'If you specify -exe=? then all EXEs defined in CompareFile''s INI will be offered to the user'
          r,←⊂'for selection or abortion of the whole process.'
          r,←⊂''
          r,←⊂'The following notes on the read-only flags are not true for KDiff3 (which allows no editing at all)'
          r,←⊂'and UltraCompare (which allows no read-only mode).'
          r,←⊂'By default both files can be edited but you can changes this by setting -ro1 / -ro2 accordingly if'
          r,←⊂'(and only if) the utility used for the comparison is supporting this.'
          r,←⊂'For example, by setting -ro1=0 -ro2=0 -ro3=0 all files can be edited while by setting -ro=0 only the'
          r,←⊂'second one could be edited.'
          r,←⊂''
          r,←⊂'The command returns a vector of two Booleans. A 1 indicates that the associated file has been changed.'
          r,←⊂''
          r,←⊂'Note that you cannot just add another comparison utility to the INI file. Because every comparison'
          r,←⊂'utility has, at least potentially, different features, arguments and switches each one needs a separate'
          r,←⊂'entry in the user command script itself. However, adding that is not a big deal.'
          r,←⊂''
          r,←⊂'-label1 and -label2 can be set as title for the two comparison panes. Might have no effect in case the'
          r,←⊂'choosen comparison tool does not support something like this. Defaults to the name of the files.'
      :EndSelect
      r,←(level=0)/⊂']',Cmd,' -??  ⍝ for syntax details'
    ∇

    ∇ {r}←LoadCompareFiles path;filename;path;ws;failed
      r←⍬
      ws←'CompareFiles\CompareFiles.dws'
      path←{⍵↓⍨-⌊/'\/'⍳⍨⌽⍵}path
      filename←path,'/',ws
      failed←1
      :Trap 11
          ⎕SE.CompareFiles.⎕CY filename
          failed←0
      :Else
          :Trap 11
              ⎕SE.CompareFiles.⎕CY ws       ⍝ Make use of Dyalog workspace search path
              failed←0
          :EndTrap
          (failed/6)⎕SIGNAL⍨'Cannot find ',ws,' in ',path
      :EndTrap
      ⍝Done
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

    ∇ (EXE NAME)←EstablishExeAndName(C Args);ind
      EXE←NAME←⍬
      :If 0≡Args.exe
          EXE←C.INI.CONFIG.EXE
          NAME←C.INI.CONFIG.Default
      :ElseIf (,'?')≡Args.exe
          ind←Select C.INI.CONFIG.Names
          →(⍬≡ind)/0
          NAME←ind⊃C.INI.CONFIG.Names
          EXE←((C.##.APLTreeUtils.Lowercase C.INI.CONFIG.Names)⍳C.##.APLTreeUtils.Lowercase C.INI.CONFIG.Names[ind])⊃C.INI.CONFIG.EXEs
      :Else
          ind←(C.##.APLTreeUtils.Lowercase C.INI.CONFIG.Names)⍳C.##.APLTreeUtils.Lowercase⊂Args.exe
          :If (≢C.INI.CONFIG.Names)<ind
              'No comparison utility found/defined'⎕SIGNAL 6
          :EndIf
          NAME←ind⊃C.INI.CONFIG.Names
          EXE←((C.##.APLTreeUtils.Lowercase C.INI.CONFIG.Names)⍳C.##.APLTreeUtils.Lowercase C.INI.CONFIG.Names[ind])⊃C.INI.CONFIG.EXEs
      :EndIf
      ⍝Done
    ∇

    ∇ filename←caption GetFilename filename;bb;flag;aa;res
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
                  'aa'⎕WC'MsgBox'('Caption' 'File selection for "CompareFiles"')('Style' 'Info')('Text'('This:'filename'is not a file - try again'))
                  ⎕DQ'aa'
              :EndIf
          :Until flag
      :EndIf
      ⍝Done
    ∇

    :Section ComparisonTools

    ∇ {r}←BeyondCompare(C EXE NAME Args);cmd;rc;processInfo;more;result
      r←⍬
      cmd←'"',(EXE~'"'),'" "',(Args._1~'"'),'" "',(Args._2~'"'),'"'
      cmd,←((,'1')≡Args.ro1)/' /ro1'
      cmd,←((,'1')≡Args.ro2)/' /ro2'
      :If (,0)≡,Args.label1
          cmd,←' /title1="',(⊃,/1↓⎕NPARTS Args._1),'"'
      :Else
          cmd,←' /title1="',Args.label1,'"'
      :EndIf
      :If (,0)≡,Args.label2
          cmd,←' /title2="',(⊃,/1↓⎕NPARTS Args._2),'"'
      :Else
          cmd,←' /title2="',Args.label2,'"'
      :EndIf
      (rc processInfo result more)←C.##.Execute.Application cmd
      ⍝Done
    ∇

    ∇ {r}←CompareIt(C EXE NAME Args);cmd;rc;processInfo;more;result
      r←⍬
      cmd←'"',(EXE~'"'),'"'
      cmd,←' "',(Args._1~'"'),'"'
      :If (,0)≡,Args.label1
          cmd,←' /=',' '~⍨⊃,/1↓⎕NPARTS Args._1
      :Else
          cmd,←' /=',Args.label1
      :EndIf
      cmd,←' "',(Args._2~'"'),'"'
      :If (,0)≡,Args.label2
          cmd,←' /=',' '~⍨⊃,/1↓⎕NPARTS Args._2
      :Else
          cmd,←' /=',Args.label2
      :EndIf
      :If (,'1')≡,Args.ro1
      :AndIf (,'1')≡,Args.ro2
          cmd,←' /R'
      :Else
          :If (,'1')≡,Args.ro1
              cmd,←' /R1'
          :ElseIf (,'1')≡,Args.ro2
              cmd,←' /R2'
          :EndIf
      :EndIf
      (rc processInfo result more)←C.##.Execute.Application cmd
      (more,'; rc=',⍕rc)⎕SIGNAL 11/⍨0≠rc
      ⍝Done
    ∇

    ∇ {r}←KDiff3(C EXE NAME Args);cmd;rc;processInfo;result;more
      r←⍬
      cmd←'"',(EXE~'"'),'" "',(Args._1~'"'),'" "',(Args._2~'"'),'"'
      :If (,0)≡,Args.label1
          cmd,←' --L1 ',' '~⍨⊃,/1↓⎕NPARTS Args._1
      :Else
          cmd,←' --L1 ',Args.label1
      :EndIf
      :If (,0)≡,Args.label2
          cmd,←' --L2 ',' '~⍨⊃,/1↓⎕NPARTS Args._2
      :Else
          cmd,←' --L2 ',Args.label2
      :EndIf
      (rc processInfo result more)←C.##.Execute.Application cmd
      (more,'; rc=',⍕rc)⎕SIGNAL 11/⍨0≠rc
      ⍝Done
    ∇

    ∇ {r}←Meld(C EXE NAME Args);cmd;rc;processInfo;result;more
      r←⍬
      cmd←'"',(EXE~'"'),'" '
      cmd,←'"',(C.##.FilesAndDirs.EnforceSlash Args._1~'"'),'"'
      cmd,←,' "',(C.##.FilesAndDirs.EnforceSlash Args._2~'"'),'"'
      (rc processInfo result more)←C.##.Execute.Application cmd
      (more,'; rc=',⍕rc)⎕SIGNAL 11/⍨0≠rc
      ⍝Done
    ∇

    ∇ {r}←UltraCompare(C EXE NAME Args);cmd;rc;processInfo;result;more
      r←⍬
      cmd←'"',(EXE~'"'),'" "',(Args._1~'"'),'" "',(Args._2~'"'),'"'
      (rc processInfo result more)←C.##.Execute.Application cmd
      (more,'; rc=',⍕rc)⎕SIGNAL 11/⍨0≠rc
      ⍝Done
    ∇

    :EndSection

:EndClass ⍝ CompareFiles
