object dmUpgrade: TdmUpgrade
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 430
  Width = 667
  object auAutoUpgrader1: TauAutoUpgrader
    InfoFile.Files.Strings = (
      
        'http://192.168.0.81/update/UtralShortReceiver2/PUtralShortReceiv' +
        'er.exe')
    InfoFileURL = 
      'http://192.168.0.81/update/BomStandardization/PBomStandardizatio' +
      'n.update.inf'
    RestartParams = ' '
    VersionControl = byNumber
    VersionDate = '04/04/2019'
    VersionDateAutoSet = True
    VersionNumber = '0.9.1.2'
    Left = 32
    Top = 16
    LInfo = {07EF818985818985}
  end
end
