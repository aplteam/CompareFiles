:Class  CompareFiles
⍝ User Command script for "CompareFiles".
⍝ Expects the WS CompareFiles.dws to be a sibling of this script.

    ⎕IO←⎕ML←1

    ∇ r←List
      :Access Shared Public
      r←⎕NS''
      r.Group←'TOOLS'
      r.Name←'CompareFiles'
      r.Parse←'2s -exe= -ro1∊01 -ro2∊01'
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
      origFile1←C.##.APLTreeUtils.ReadUtf8File Args._1
      origFile2←C.##.APLTreeUtils.ReadUtf8File Args._2
      :Select NAME
      :Case 'KDiff3'
          KDiff3 C EXE NAME Args
      :Case 'BeyondCompare'
          BeyondCompare C EXE NAME Args
      :Case 'CompareIt'
          CompareIt C EXE NAME Args
      :EndSelect
      file1←C.##.APLTreeUtils.ReadUtf8File Args._1
      file2←C.##.APLTreeUtils.ReadUtf8File Args._2
      r←(origFile1≢file1)(origFile2≢file2)
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
    ∇

    ∇ {r}←BeyondCompare(C EXE NAME Args);cmd;rc
      r←⍬
      cmd←'"',(EXE~'"'),'" ',Args._1,' ',Args._2
      cmd,←((,'1')≡Args.ro1)/' /ro1'
      cmd,←((,'1')≡Args.ro2)/' /ro2'
      cmd,←' /title1=',⊃,/1↓⎕NPARTS Args._1
      cmd,←' /title2=',⊃,/1↓⎕NPARTS Args._2
      rc←⎕CMD cmd
    ∇

    ∇ {r}←CompareIt(C EXE NAME Args);cmd;rc;processInfo;more;result
      r←⍬
      cmd←'"',(EXE~'"'),'" ',Args._1,' ',Args._2
      cmd,←' /=',⊃,/1↓⎕NPARTS Args._1
      cmd,←' /=',⊃,/1↓⎕NPARTS Args._2
      cmd,←((,'1')≡Args.ro1)/' /R1'
      cmd,←((,'1')≡Args.ro2)/' /R2'
      (rc processInfo result more)←C.##.Execute.Application cmd
      (more,'; rc=',⍕rc)⎕SIGNAL 11/⍨0≠rc
    ∇

    ∇ {r}←KDiff3(C EXE NAME Args);cmd;rc;processInfo;result;more
      r←⍬
      'KDiff3 does not support edit mode'⎕SIGNAL 11/⍨'00'≢∊Args.(ro1 ro2)
      cmd←'"',(EXE~'"'),'" ',Args._1,' ',Args._2
      cmd,←' --L1 ',⊃,/1↓⎕NPARTS Args._1
      cmd,←' --L1 ',⊃,/1↓⎕NPARTS Args._2
      (rc processInfo result more)←C.##.Execute.Application cmd
      (more,'; rc=',⍕rc)⎕SIGNAL 11/⍨0≠rc
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
          EXE←(C.INI.CONFIG.Names⍳C.INI.CONFIG.Names[ind])⊃C.INI.CONFIG.EXEs
      :Else
          'No comparison utility found/defined'⎕SIGNAL 6
      :EndIf
    ∇

:EndClass ⍝ CompareFiles
