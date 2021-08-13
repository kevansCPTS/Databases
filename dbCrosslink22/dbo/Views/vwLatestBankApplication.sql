

CREATE VIEW [dbo].[vwLatestBankApplication]
AS

    select
        ba.AccountID
    ,   ba.UserID
    ,   ba.Efin
	,	ba.IPAddress
    ,   ba.EfinID
    ,   ba.Bank
    ,   ba.BankID
    ,   ba.BankAppID
    ,   ba.Delivered
    ,   ba.[Sent]
    ,   ba.DeliveredDate
    ,   ba.SentDate
    ,   ba.Deleted
    ,   ba.UpdatedDate
    ,   ba.SubmittedRecordType
    ,   ba.[Master]
    ,   ba.EIN
    ,   ba.EFINHolderSSN 
    ,   ba.EFINHolderFirstName
    ,   ba.EFINHolderLastName
    ,   ba.EFINHolderDOB
    ,   ba.Company
    ,   ba.[Address]
    ,   ba.City
    ,   ba.[State]
    ,   ba.Zip 
    ,   ba.Phone
    ,   ba.AlternatePhone
    ,   ba.Fax
    ,   ba.Email
    ,   ba.FeeRoutingNumber
    ,   ba.FeeAccountNumber
    ,   ba.FeeAccountType
    ,   ba.FeeAccountName 
    ,   ba.PEITechFee
    ,   ba.PEIRALTransmitterFee
    ,   ba.EROTranFee
    ,   ba.EROBankFee 
    ,   ba.SBPrepFee
    ,   ba.Roll
    ,   ba.EfinStatus
    ,   ba.ErrorCode
    ,   ba.EfinProduct 
    ,   ba.ErrorDescription 
    ,   ba.Registered
    ,   ba.RegisteredDescription
    ,   ba.DistributorId
    ,   ba.CompanyId
    ,   ba.LocationId
    ,   ba.CheckName 
    ,   ba.SBFeeAll
    ,   ba.HoldFlag
    ,   ba.RacsOnly
    ,   ba.SBName
    ,   ba.AllowMultipleBanks
    ,   ba.LockedAtBank
    ,   ba.SelectedBank 
    ,   ba.SelectedBankName
    ,   ba.SCOStatus
    ,   ba.DocPrepFee
    ,   ba.EFilingFee
    ,   ba.SystemHold
    ,   ba.EfinBankFee
    ,   ba.EfinCompliance
    ,   ba.EfinCard
    ,   ba.EfinPrint
    ,   ba.EfinProduct2
    ,   ba.[Hidden]
    ,	ba.NetTranFee
	,	ba.CPTSAdminFee
	,	ba.EFFee
	,	ba.NetEFFee
	,	ba.CPTSAdminEFFee
	,	ba.EFFeeAll
	,   ba.TechFee
	,   ba.NetTechFee
	,   ba.CPTSAdminTechFee
	,   ba.SuperSBid 
    from
        (
            select
                ba1.AccountID
            ,   ba1.UserID
            ,   ba1.Efin
			,   ba1.IPAddress
            ,   ba1.EfinID
            ,   ba1.Bank
            ,   ba1.BankID
            ,   ba1.BankAppID
            ,   ba1.Delivered
            ,   ba1.[Sent]
            ,   ba1.DeliveredDate
            ,   ba1.SentDate
            ,   ba1.Deleted
            ,   ba1.UpdatedDate
            ,   ba1.SubmittedRecordType
            ,   ba1.[Master]
            ,   ba1.EIN
            ,   ba1.EFINHolderSSN 
            ,   ba1.EFINHolderFirstName
            ,   ba1.EFINHolderLastName
            ,   ba1.EFINHolderDOB
            ,   ba1.Company
            ,   ba1.[Address]
            ,   ba1.City
            ,   ba1.[State]
            ,   ba1.Zip 
            ,   ba1.Phone
            ,   ba1.AlternatePhone
            ,   ba1.Fax
            ,   ba1.Email
            ,   ba1.FeeRoutingNumber
            ,   ba1.FeeAccountNumber
            ,   ba1.FeeAccountType
            ,   ba1.FeeAccountName 
            ,   ba1.PEITechFee
            ,   ba1.PEIRALTransmitterFee
            ,   ba1.EROTranFee
            ,   ba1.EROBankFee 
            ,   ba1.SBPrepFee
            ,   ba1.Roll
            ,   ba1.EfinStatus
            ,   ba1.ErrorCode
            ,   ba1.EfinProduct 
            ,   ba1.ErrorDescription 
            ,   ba1.Registered
            ,   ba1.RegisteredDescription
            ,   ba1.DistributorId
            ,   ba1.CompanyId
            ,   ba1.LocationId
            ,   ba1.CheckName 
            ,   ba1.SBFeeAll
            ,   ba1.HoldFlag
            ,   ba1.RacsOnly
            ,   ba1.SBName
            ,   ba1.AllowMultipleBanks
            ,   ba1.LockedAtBank
            ,   ba1.SelectedBank 
            ,   ba1.SelectedBankName
            ,   ba1.SCOStatus
            ,   ba1.DocPrepFee
            ,   ba1.EFilingFee
            ,   ba1.SystemHold
            ,   ba1.EfinBankFee
            ,   ba1.EfinCompliance
            ,   ba1.EfinCard
            ,   ba1.EfinPrint
            ,   ba1.EfinProduct2
            ,   ba1.[Hidden]
			,	ba1.NetTranFee
			,	ba1.CPTSAdminFee
			,	ba1.EFFee
			,	ba1.NetEFFee
			,	ba1.CPTSAdminEFFee
			,	ba1.EFFeeAll
			,   ba1.TechFee
			,   ba1.NetTechFee
			,   ba1.CPTSAdminTechFee
			,   ba1.SuperSBid 
            ,   row_number() over ( partition by ba1.EfinID,ba1.BankID order by ba1.BankAppID desc) AS RowNumber
            from 
                dbo.vwBankApplication ba1
        ) ba
    where
        ba.RowNumber = 1









GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[28] 4[18] 2[32] 3) )"
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
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwBankApplication"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "#LatestApp"
            Begin Extent = 
               Top = 6
               Left = 273
               Bottom = 118
               Right = 443
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
      Begin ColumnWidths = 58
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
       ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwLatestBankApplication';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwLatestBankApplication';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwLatestBankApplication';

