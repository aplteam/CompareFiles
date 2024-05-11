:Class  CompareFiles_uc
⍝ User Command script for "CompareFiles".
⍝ Kai Jaeger - APL Team Ltd
⍝ Version 4.0.0 from 2024-05-09

    ⎕IO←⎕ML←1

    ∇ r←List;res;⎕TRAP
      :Access Shared Public
      r←⎕NS''
      r.Group←'TOOLS'
      r.Name←'CompareFiles'
      r.Parse←'2s -edit1 -edit2 -caption1= -caption2= -use= -save -version -config -editconfig'
      r.Desc←'Compare two files with each other.'
      ⍝Done
    ∇

    ∇ r←Run(Cmd Args);fn1;fn2;fn3;parms;stdOut;rc;stdErr;orig1;orig2;orig3;exe;name
      :Access Shared Public
      r←''
      :If 0=⎕SE.⎕NC'CompareFiles'
          {}⎕SE.Tatin.LoadDependencies(⊃⎕NPARTS ##.SourceFile)⎕SE
      :EndIf
      C←GetRefToCompareFiles ⍬
      CT←C.##.ComparisonTools
      C.##.Init ⍬
      :If 0 Args.Switch'version'
          r←C.Version
      :ElseIf 0 Args.Switch'config'
          r←C.##.F.NormalizePath C.##.GetConfigFilename
      :ElseIf 0 Args.Switch'editconfig'
          r←C.##.EditConfigFile ⍬
      :Else
          :If (,0)≢,Args.use        ⍝ "use" can be expected...
          :AndIf 0<≢Args.use        ⍝ ... to be the name of a comparison utility (or "?")...
          :AndIf 0 0≡Args.(_1 _2)   ⍝ ... and there are no filenames specified
              (exe name)←C.Use Args.use
              :Return
          :EndIf
          'Please specify two files'⎕SIGNAL 2/⍨2≠≢Args.Arguments
          '⍵[1] is not a file'Assert ⎕NEXISTS Args._1
          '⍵[2] is not a file'Assert ⎕NEXISTS Args._2
          :If ≡/LowercaseIfWindows¨Args._1 Args._2
              'Comparing a file with itself makes no sense'⎕SIGNAL 911
          :EndIf
          (exe name)←C.EstablishCompareEXE{0≡⍵:'' ⋄ ⍵}Args.use
          →(0=≢exe)/0
          ('Missing: function "CreateParmsFor',({⍵↑⍨¯1+⍵⍳' '}name),'"')Assert 3=C.##.ComparisonTools.⎕NC'CreateParmsFor',{⍵↑⍨¯1+⍵⍳' '}name
          parms←C.ComparisonTools.⍎'CreateParmsFor',{⍵↑⍨¯1+⍵⍳' '}name
          parms.use←exe
          parms.name←{⍵↑⍨¯1+⍵⍳' '}name
          parms.file1←'Please select first filename'GetFilename Args._1
          →(0=≢parms.file1)/0
          parms.file2←'Please select second filename'GetFilename Args._2
          →(0=≢parms.file2)/0
          parms.(file1 file2)←{'expand'C.##.FilesAndDirs.NormalizePath ⍵}¨parms.(file1 file2)
          parms.(caption1 caption2)←parms.(file1 file2){0≡⍵:⍺ ⋄ ⍵}¨Args.(caption1 caption2)
          (orig1 orig2)←ReadFile¨parms.(file1 file2)
          :If 2=parms.⎕NC'edit1'
          :AndIf parms.edit1≠Args.edit1
              parms.edit1←Args.edit1
          :EndIf
          :If 2=parms.⎕NC'edit1'
          :AndIf parms.edit2≠Args.edit2
              parms.edit2←Args.edit2
          :EndIf
          parms.saveFlag←Args.save
          (rc stdOut stdErr)←C.Compare parms
          stdOut Assert rc=0
          r←2⍴0
          :If 0<≢parms.file1
          :AndIf parms.edit1
              r[1]←orig1≢ReadFile parms.file1
          :EndIf
          :If 0<≢parms.file2
          :AndIf parms.edit2
              r[2]←orig2≢ReadFile parms.file2
          :EndIf
      :EndIf
    ∇

    ∇ C←GetRefToCompareFiles dummy;ind;linkList
      :If 0<⎕NC'⎕SE.Link'
      :AndIf 2=⍴⍴linkList←⎕SE.Link.Status''
      :AndIf 0<≢linkList←1↓linkList
          ind←linkList[;1]⍳⊂'#.CompareFiles'
      :AndIf (≢linkList)≥ind
      :AndIf 1 ⎕SE.CompareFiles.##.CommTools.YesOrNo'Execute code in #.CompareFiles rather than ⎕SE.CompareFiles?'
          C←#.CompareFiles.CompareFiles.API
      :Else
          C←⎕SE.CompareFiles
      :EndIf
    ∇

    ∇ r←level Help Cmd
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          r,←⊂List.Desc
      :Case 1
          r,←⊂'Specify two filenames as arguments. These files will then be compared with one of the'
          r,←⊂'compare utilities defined in the config file - see below.'
          r,←⊂''
          r,←⊂'Naturally utilities that are not available are ignored. The user might select one from'
          r,←⊂'the remaining list if there is more than just one left.'
          r,←⊂'Instead you may specify a comparison utility with -use= by assigning the name as'
          r,←⊂'defined in the config file.'
          r,←⊂''
          r,←⊂'By default no file can be edited, but you can change this by specifying either -edit1'
          r,←⊂'and/or -edit2, allowing just the corresponding file to be edited. Of course this is'
          r,←⊂'true only if the chosen comparison utility is supporting this: some do not support'
          r,←⊂'read-only, some do not support editing files.'
          r,←⊂''
          r,←⊂'-caption1= and -caption2= can be set as caption for the comparison panes. Might have no'
          r,←⊂'effect in case the chosen comparison tool does not support something like this.'
          r,←⊂'Defaults to the name of the files.'
          r,←⊂''
          r,←⊂'-use= allows you to specify the name of one of the comparison utilities. If you are not'
          r,←⊂'      sure then specify -use=? and you will get a list with all utilities available.'
          r,←⊂'      You may omit the filenames if you want to set just the default comparison utility.'
          r,←⊂''
          r,←⊂'-save This flag can be used to make the change permanent issued by specifying -use='
          r,←⊂'      This implies that -save is ignored in case -use= was not set.'
          r,←⊂''
          r,←⊂'The command returns a vector of two Booleans.'
          r,←⊂'A 1 indicates that the associated file has been changed.'
          r,←⊂''
          r,←⊂'-version     Returns the version number. If specified everything else is ignored.'
          r,←⊂'-config      Returns the full path of the config file'
          r,←⊂'-editconfig  Allows you to edit the config file'
      :Case 2
          r,←⊂'In order to add your favourite comparison utility follow this recipe:'
          r,←⊂''
          r,←⊂' 1. Edit the config file and add your favourite utility'
          r,←⊂' 2. For a utility "Foo" add a function Foo.aplf to the folder that hosts the config file'
          r,←⊂' 3. Add also a function CreateParmsForFoo.aplf to that folder as well'
          r,←⊂''
          r,←⊂'Investigate the pre-defined comparison utility "CompareIt" in ⎕SE.CompareFiles.ComparisonTools'
          r,←⊂'in order to find out what "Foo.aplf" and "CreateParmsForFoo.aplf" are expected to look like.'
          r,←⊂''
          r,←⊂'Not all comparison utilities require/support all options, but CompareIt does:'
          r,←⊂' * There are two flags for toggling the left & right pane between edit/read-only'
          r,←⊂' * There are two options for setting the caption of the left and right pane'
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

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⎕ML←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),911}

:EndClass
