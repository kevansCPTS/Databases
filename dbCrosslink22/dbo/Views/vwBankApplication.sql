
/**
This is the generic query which will return every application and it's latest 
bank response (if there is one).

With */
CREATE VIEW [dbo].[vwBankApplication]
AS
SELECT        dbo.efin.Account AS AccountID, dbo.efin.UserID, dbo.efin.Efin, [#Apps].IPAddress, [#Apps].EfinID, [#Apps].Bank, [#Apps].BankID, [#Apps].BankAppID, [#Apps].Delivered, [#Apps].Sent, [#Apps].DeliveredDate, [#Apps].SentDate, 
                         [#Apps].Deleted, [#Apps].UpdatedDate, [#Apps].SubmittedRecordType, [#Apps].Master, [#Apps].EIN, [#Apps].EFINHolderSSN, [#Apps].EFINHolderFirstName, [#Apps].EFINHolderLastName, [#Apps].EFINHolderDOB, 
                         [#Apps].Company, [#Apps].Address, [#Apps].City, [#Apps].State, [#Apps].Zip, [#Apps].Phone, [#Apps].AlternatePhone, [#Apps].Fax, [#Apps].Email, [#Apps].FeeRoutingNumber, [#Apps].FeeAccountNumber, [#Apps].FeeAccountType, 
                         [#Apps].FeeAccountName, [#Apps].PEITechFee, [#Apps].PEIRALTransmitterFee, [#Apps].EROTranFee, (CASE WHEN #Apps.BankID = 'F' THEN efin.EROBankFee ELSE 0 END) AS EROBankFee, [#Apps].SBPrepFee, [#Apps].Roll, 
                         efin_regr_1.EfinStatus, efin_regr_1.EfinError AS ErrorCode, efin_regr_1.EfinProduct, (CASE WHEN #Apps.BankID = 'A' THEN efin_regr_1.ErrorDescription ELSE dbo.ltblBankRegRejects.RejectDescription END) 
                         AS ErrorDescription, (CASE WHEN BankStatus.Registered IS NOT NULL THEN BankStatus.Registered ELSE (CASE WHEN #Apps.Delivered = 1 THEN 'P' ELSE 'U' END) END) AS Registered, 
                         StatusDescription.Description AS RegisteredDescription, dbo.efin.DistributorId, dbo.efin.CompanyId, dbo.efin.LocationId, dbo.efin.CheckName, dbo.efin.SBFeeAll, ISNULL(dbo.efin.HoldFlag, 'N') AS HoldFlag, 
                         (CASE WHEN [#Apps].BankID = 'R' AND efin_regr_1.EFINProduct = 'A' THEN 'N' ELSE 'Y' END) AS RacsOnly, dbCrosslinkGlobal.dbo.customer.SBName, dbo.efin.AllowMultipleBanks, BankStatus.LockedAtBank, 
                         dbo.efin.SelectedBank, SelectedBank.BankName AS SelectedBankName, dbo.efin.SCOStatus, [#Apps].DocPrepFee, [#Apps].EFilingFee, [#Apps].SystemHold, efin_regr_1.EfinBankFee, efin_regr_1.EfinCompliance, 
                         efin_regr_1.EfinCard, efin_regr_1.EfinPrint, efin_regr_1.EfinProduct2, [#Apps].Hidden, [#Apps].NetTranFee, [#Apps].CPTSAdminFee, [#Apps].EFFee, [#Apps].NetEFFee, [#Apps].CPTSAdminEFFee, dbo.efin.EFFeeAll,
						 [#Apps].TechFee, [#Apps].NetTechFee, [#Apps].CPTSAdminTechFee, [#Apps].SuperSBid
FROM            dbo.efin INNER JOIN
                             (SELECT        EfinID, UserID, 'TPG' AS Bank, 'S' AS BankID, SBTPG_BankAppID AS BankAppID, Delivered, Sent, DeliveredDate, SentDate, Deleted, UpdatedDate, SubmittedRecordType, Master, 
                                                         (CASE WHEN IsNumeric(OwnersEIN) = 1 THEN OwnersEIN ELSE 0 END) AS EIN, OwnersSSN AS EFINHolderSSN, OwnersFirstName AS EFINHolderFirstName, OwnersLastName AS EFINHolderLastName, 
                                                         OwnersDateOfBirth AS EFINHolderDOB, CompanyName AS Company, OfficeAddress AS Address, OfficeCity AS City, OfficeState AS State, OfficeZipCode AS Zip, OfficePhoneNumber AS Phone, 
                                                         OwnersPhoneNumber AS AlternatePhone, OfficeFaxNumber AS Fax, ManagersEmailAddress AS Email, FeeRoutingNumber, FeeAccountNumber, FeeAccountType, '' AS FeeAccountName, PEITechFee, 
                                                         PEIRALTransmitterFee, EROTranFee, SBPrepFee, Roll, NULL AS DistributorId, NULL AS CompanyId, NULL AS LocationId, DocPrepFee, NULL AS EFilingFee, SystemHold, Hidden, IPAddress, NetTranFee, 
                                                         CPTSAdminFee, EFFee, NetEFFee, CPTSAdminEFFee, TechFee, NetTechFee, CPTSAdminTechFee, SuperSBid
                               FROM            dbo.SBTPG_BankApp
                               UNION
                               SELECT        EfinID, UserID, 'TPGW' AS Bank, 'W' AS BankID, SBTPGW_BankAppID AS BankAppID, Delivered, Sent, DeliveredDate, SentDate, Deleted, UpdatedDate, SubmittedRecordType, Master, 
                                                        (CASE WHEN IsNumeric(OwnersEIN) = 1 THEN OwnersEIN ELSE 0 END) AS EIN, OwnersSSN AS EFINHolderSSN, OwnersFirstName AS EFINHolderFirstName, OwnersLastName AS EFINHolderLastName, 
                                                        OwnersDateOfBirth AS EFINHolderDOB, CompanyName AS Company, OfficeAddress AS Address, OfficeCity AS City, OfficeState AS State, OfficeZipCode AS Zip, OfficePhoneNumber AS Phone, 
                                                        OwnersPhoneNumber AS AlternatePhone, OfficeFaxNumber AS Fax, ManagersEmailAddress AS Email, FeeRoutingNumber, FeeAccountNumber, FeeAccountType, '' AS FeeAccountName, PEITechFee, 
                                                        PEIRALTransmitterFee, EROTranFee, SBPrepFee, Roll, NULL AS DistributorId, NULL AS CompanyId, NULL AS LocationId, DocPrepFee, NULL AS EFilingFee, SystemHold, Hidden, IPAddress, NetTranFee, 
                                                        CPTSAdminFee, EFFee, NetEFFee, CPTSAdminEFFee, TechFee, NetTechFee, CPTSAdminTechFee, SuperSBid
                               FROM            dbo.SBTPGW_BankApp
                               UNION
                               SELECT        EfinID, UserID, 'Republic' AS Bank, 'R' AS BankID, Republic_BankAppID AS BankAppID, Delivered, Sent, DeliveredDate, SentDate, Deleted, UpdatedDate, SubmittedRecordType, Master, NULL AS EIN, 
                                                        EfinOwnerSSN AS EFINHolderSSN, EfinOwnerFirstName AS EFINHolderFirstName, EfinOwnerLastName AS EFINHolderLastName, EFINOwnerDOB AS EFINHolderDOB, OfficeName AS Company, 
                                                        OfficePhysicalStreet AS Address, OfficePhysicalCity AS City, OfficePhysicalState AS State, OfficePhysicalZip AS Zip, OfficePhoneNumber AS Phone, CellPhoneNumber AS AlternatePhone, FaxNumber AS Fax, 
                                                        EmailAddress AS Email, FeeRoutingNumber, FeeAccountNumber, FeeAccountType, FeeAccountName, PEITechFee, PEIRALTransmitterFee, EROTranFee, SBPrepFee, Roll, NULL AS DistributorId, NULL 
                                                        AS CompanyId, NULL AS LocationId, DocPrepFee, NULL AS EFilingFee, SystemHold, Hidden, IPAddress, NetTranFee, CPTSAdminFee, EFFee, NetEFFee, CPTSAdminEFFee, TechFee, NetTechFee, CPTSAdminTechFee, SuperSBid 
                               FROM            dbo.Republic_BankApp
                               UNION
                               SELECT        EfinID, UserID, 'Refundo' AS Bank, 'F' AS BankID, Refundo_BankAppID AS BankAppID, Delivered, Sent, DeliveredDate, SentDate, Deleted, UpdatedDate, SubmittedRecordType, Master, NULL AS EIN, 
                                                        EfinOwnerSSN AS EFINHolderSSN, EfinOwnerFirstName AS EFINHolderFirstName, EfinOwnerLastName AS EFINHolderLastName, EFINOwnerDOB AS EFINHolderDOB, OfficeName AS Company, 
                                                        OfficePhysicalStreet AS Address, OfficePhysicalCity AS City, OfficePhysicalState AS State, OfficePhysicalZip AS Zip, OfficePhoneNumber AS Phone, CellPhoneNumber AS AlternatePhone, FaxNumber AS Fax, 
                                                        EmailAddress AS Email, FeeRoutingNumber, FeeAccountNumber, FeeAccountType, '' AS FeeAccountName, PEITechFee, PEIRALTransmitterFee, EROTranFee, SBPrepFee, Roll, NULL AS DistributorId, NULL 
                                                        AS CompanyId, NULL AS LocationId, DocPrepFee, NULL AS EFilingFee, SystemHold, Hidden, IPAddress, NetTranFee, CPTSAdminFee, EFFee, NetEFFee, CPTSAdminEFFee, TechFee, NetTechFee, CPTSAdminTechFee, SuperSBid
                               FROM            dbo.Refundo_BankApp
                               UNION
                               SELECT        EfinID, UserID, 'Refund Advantage' AS Bank, 'V' AS BankID, Refund_Advantage_BankAppID AS BankAppID, Delivered, Sent, DeliveredDate, SentDate, Deleted, UpdatedDate, ' ' AS SubmittedRecordType, Master, 
                                                        0 AS EIN, EFINOwnerSSN AS EFINHolderSSN, EFINOwnerFirstName AS EFINHolderFirstName, EFINOwnerLastName AS EFINHolderLastName, EFINOwnerDateOfBirth AS EFINHolderDOB, OfficeName AS Company, 
                                                        OfficeAddressStreet AS Address, OfficeAddressCity AS City, OfficeAddressState AS State, OfficeAddressZip AS Zip, OfficePhone AS Phone, '' AS AlternatePhone, OfficeFax AS Fax, '' AS Email, FeeRoutingNumber, 
                                                        FeeAccountNumber, FeeAccountType, '' AS FeeAccountName, PEITechFee, PEIRALTransmitterFee, EROTranFee, SBFee AS SBPrepFee, Roll, NULL AS DistributorId, NULL AS CompanyId, NULL AS LocationId, NULL 
                                                        AS DocPrepFee, EFilingFee, SystemHold, Hidden, IPAddress, NetTranFee, CPTSAdminFee, EFFee, NetEFFee, CPTSAdminEFFee, TechFee, NetTechFee, CPTSAdminTechFee, SuperSBid
                               FROM            dbo.Refund_Advantage_BankApp) AS [#Apps] ON dbo.efin.EfinID = [#Apps].EfinID AND dbo.efin.UserID = [#Apps].UserID LEFT OUTER JOIN
                             (SELECT        BankCode, BankAppID, MAX(rowID) AS RegrRowID
                               FROM            dbo.efin_regr
                               GROUP BY BankCode, BankAppID) AS [#LASTRESPONSE] ON [#LASTRESPONSE].BankCode = [#Apps].BankID AND [#LASTRESPONSE].BankAppID = [#Apps].BankAppID LEFT OUTER JOIN
                         dbo.efin_regr AS efin_regr_1 ON [#LASTRESPONSE].RegrRowID = efin_regr_1.rowID LEFT OUTER JOIN
                         dbo.ltblBankRegRejects ON efin_regr_1.EfinError = dbo.ltblBankRegRejects.RejectCode AND efin_regr_1.BankCode = dbo.ltblBankRegRejects.Bank LEFT OUTER JOIN
                         dbo.ltblBankRegistrationStatus AS BankStatus ON BankStatus.BankID = efin_regr_1.BankCode AND BankStatus.EFINStatus = efin_regr_1.EfinStatus LEFT OUTER JOIN
                         dbo.ltblRegistrationStatusDescription AS StatusDescription ON StatusDescription.Registered = (CASE WHEN BankStatus.Registered IS NOT NULL 
                         THEN BankStatus.Registered ELSE (CASE WHEN #Apps.Delivered = 1 THEN 'P' ELSE 'U' END) END) LEFT OUTER JOIN
                         dbCrosslinkGlobal.dbo.customer ON dbCrosslinkGlobal.dbo.customer.account = dbo.efin.Account LEFT OUTER JOIN
                         dbo.EFINBank AS SelectedBank ON SelectedBank.EFINBankID = dbo.efin.SelectedBank

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[13] 2[46] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "efin"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "#LASTRESPONSE"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 239
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "efin_regr_1"
            Begin Extent = 
               Top = 6
               Left = 692
               Bottom = 125
               Right = 876
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ltblBankRegRejects"
            Begin Extent = 
               Top = 114
               Left = 494
               Bottom = 233
               Right = 667
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BankStatus"
            Begin Extent = 
               Top = 6
               Left = 494
               Bottom = 110
               Right = 654
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StatusDescription"
            Begin Extent = 
               Top = 126
               Left = 236
               Bottom = 215
               Right = 396
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "customer (dbCrosslinkGlobal.dbo)"
            Begin Extent = 
               Top = 216
               Left = 236
               Bottom = 335
               Righ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwBankApplication';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N't = 426
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SelectedBank"
            Begin Extent = 
               Top = 102
               Left = 914
               Bottom = 221
               Right = 1109
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "#Apps"
            Begin Extent = 
               Top = 126
               Left = 705
               Bottom = 256
               Right = 911
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 54
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwBankApplication';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwBankApplication';

