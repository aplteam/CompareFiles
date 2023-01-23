:Class  CompareFiles_uc
⍝ User Command script for "CompareFiles".
⍝ Kai Jaeger - APL Team Ltd
⍝ Version 3.0.0 from 2023-01-23

    ⎕IO←⎕ML←1

    ∇ r←List;res;⎕TRAP
      :Access Shared Public
      r←⎕NS''
      r.Group←'TOOLS'
      r.Name←'CompareFiles'
      r.Parse←'2s -edit1 -edit2 -caption1= -caption2= -use= -save -version'
      r.Desc←'Compare two files with each other.'
      ⍝Done
    ∇

    ∇ r←Run(Cmd Args);fn1;fn2;fn3;parms;stdOut;rc;stdErr;orig1;orig2;orig3;exe;name
      :Access Shared Public
      r←''
      C←⎕SE.CompareFiles
      CT←C.##.ComparisonTools
      C.##.Init ⍬
      :If 0 Args.Switch'version'
          r←C.Version
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
          ('Missing: function "CreateParmsFor',name,'"')Assert 3=⎕se.CompareFiles.ComparisonTools.⎕NC'CreateParmsFor',name
          parms←⎕se.CompareFiles.ComparisonTools.⍎'CreateParmsFor',name
          parms.use←exe
          parms.name←name
          parms.file1←'Please select first filename'GetFilename Args._1
          →(0=≢parms.file1)/0
          parms.file2←'Please select second filename'GetFilename Args._2
          →(0=≢parms.file2)/0
          parms.(file1 file2)←{'expand'C.##.FilesAndDirs.NormalizePath ⍵}¨parms.(file1 file2)
          parms.(caption1 caption2)←parms.(file1 file2){0≡⍵:⍺ ⋄ ⍵}¨Args.(caption1 caption2)
          (orig1 orig2)←ReadFile¨parms.(file1 file2)
          parms.(edit1 edit2)←Args.(edit1 edit2)
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

    ∇ r←level Help Cmd
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          r,←⊂List.Desc
      :Case 1
          r,←⊂'Specify two filenames as arguments. These files will then be compared with one of the'
          r,←⊂'compare utilities defined in "ini.json5" - see below.'
          r,←⊂''
          r,←⊂'Naturally utilities that are not available are ignored. The user might select one from'
          r,←⊂'the remaining list if there are more than just one left.'
          r,←⊂'Instead you may specify a comparison utility with -use= by assigning the name as'
          r,←⊂'defined in the "ini.json5" file. Either way, your choice will be remembered.'
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
          r,←⊂'-save This flag can be used to make the change permanent issued by passing the -use.'
          r,←⊂'parameter. This implies that it is ignored in case -use= was not set.'
          r,←⊂''
          r,←⊂'The command returns a vector of two Booleans.'
          r,←⊂'A 1 indicates that the associated file has been changed.'
          r,←⊂''
          r,←⊂'-version returns the version number. If specified everything else is ignored.'
          r,←⊂''
          r,←⊂'Note that you can add your favourite comparison utility; enter:'
          r,←⊂']CompareFiles -???'
          r,←⊂'for how to do that.'
      :Case 2
          r,←⊂'In order to add your favourite comparison utility follow this recipe:'
          r,←⊂''
          r,←⊂' 1. Execute ⎕SE.CompareFiles.GetPathToINI in order to find out where the INI file lives'
          r,←⊂' 2. Edit the ini file ini.json5 in that folder and add your favourite utility'
          r,←⊂' 3. For a utility "Foo" add a function Foo.aplf to that folder'
          r,←⊂' 4. Add also a function CreateParmsForFoo.aplf to that folder'
          r,←⊂''
          r,←⊂'Investigate the pre-defined comparison utility "CompareIt" in ⎕SE.CompareFiles.ComparisonTools'
          r,←⊂'in order to find out what "Foo.aplf" and "CreateParmsForFoo.aplf" are expected to look like.'
          r,←⊂'(Not all comparison utilities require all options, but CompareIt does)'
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
