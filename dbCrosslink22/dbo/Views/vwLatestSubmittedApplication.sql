
CREATE VIEW [dbo].[vwLatestSubmittedApplication]
--With 
--    Schemabinding
AS
	select        
		vba.AccountID
	,   vba.UserID
	,   vba.Efin
	,   vba.IPAddress
	,   vba.EfinID
	,   vba.Bank
	,   vba.BankID
	,   vba.BankAppID
	,   vba.Delivered
	,   vba.[Sent]
	,   vba.DeliveredDate
	,   vba.SentDate
	,   vba.Deleted
	,   vba.UpdatedDate
	,   vba.SubmittedRecordType
	,   vba.[Master]
	,   vba.EIN
	,   vba.EFINHolderSSN
	,   vba.EFINHolderFirstName
	,   vba.EFINHolderLastName
	,   vba.EFINHolderDOB
	,   vba.Company
	,   vba.[Address]
	,   vba.City
	,   vba.[State]
	,   vba.Zip
	,   vba.Phone
	,   vba.AlternatePhone
	,   vba.Fax
	,   vba.Email
	,   vba.FeeRoutingNumber
	,   vba.FeeAccountNumber
	,   vba.FeeAccountType
	,   vba.FeeAccountName
	,   vba.PEITechFee
	,   vba.PEIRALTransmitterFee
	,   vba.EROTranFee
	,   vba.EROBankFee
	,   vba.SBPrepFee
	,   vba.Roll
	,   vba.EfinStatus
	,   vba.ErrorCode
	,   vba.EfinProduct
	,   vba.ErrorDescription
	,   vba.Registered
	,   vba.RegisteredDescription
	,   vba.DistributorId
	,   vba.CompanyId
	,   vba.LocationId
	,   vba.CheckName
	,   vba.SBFeeAll
	,   vba.HoldFlag
	,   vba.RacsOnly
	,   vba.SBName
	,   vba.AllowMultipleBanks
	,   vba.LockedAtBank
	,   vba.SelectedBank
	,   vba.SelectedBankName
	,   vba.SCOStatus
	,   vba.DocPrepFee
	,   vba.EFilingFee
	,   vba.SystemHold
	,   vba.[Hidden]
    ,   vba.NetTranFee
	,	vba.CPTSAdminFee
	,	vba.EFFee
	,	vba.NetEFFee
	,	vba.CPTSAdminEFFee
	,	vba.EFFeeAll
	,   vba.TechFee
	,   vba.NetTechFee
	,   vba.CPTSAdminTechFee
	,   vba.SuperSBid 
	from
		(
			select        
				vba1.AccountID
			,   vba1.UserID
			,   vba1.Efin
			,	vba1.IPAddress
			,   vba1.EfinID
			,   vba1.Bank
			,   vba1.BankID
			,   vba1.BankAppID
			,   vba1.Delivered
			,   vba1.[Sent]
			,   vba1.DeliveredDate
			,   vba1.SentDate
			,   vba1.Deleted
			,   vba1.UpdatedDate
			,   vba1.SubmittedRecordType
			,   vba1.[Master]
			,   vba1.EIN
			,   vba1.EFINHolderSSN
			,   vba1.EFINHolderFirstName
			,   vba1.EFINHolderLastName
			,   vba1.EFINHolderDOB
			,   vba1.Company
			,   vba1.[Address]
			,   vba1.City
			,   vba1.[State]
			,   vba1.Zip
			,   vba1.Phone
			,   vba1.AlternatePhone
			,   vba1.Fax
			,   vba1.Email
			,   vba1.FeeRoutingNumber
			,   vba1.FeeAccountNumber
			,   vba1.FeeAccountType
			,   vba1.FeeAccountName
			,   vba1.PEITechFee
			,   vba1.PEIRALTransmitterFee
			,   vba1.EROTranFee
			,   vba1.EROBankFee
			,   vba1.SBPrepFee
			,   vba1.Roll
			,   vba1.EfinStatus
			,   vba1.ErrorCode
			,   vba1.EfinProduct
			,   vba1.ErrorDescription
			,   vba1.Registered
			,   vba1.RegisteredDescription
			,   vba1.DistributorId
			,   vba1.CompanyId
			,   vba1.LocationId
			,   vba1.CheckName
			,   vba1.SBFeeAll
			,   vba1.HoldFlag
			,   vba1.RacsOnly
			,   vba1.SBName
			,   vba1.AllowMultipleBanks
			,   vba1.LockedAtBank
			,   vba1.SelectedBank
			,   vba1.SelectedBankName
			,   vba1.SCOStatus
			,   vba1.DocPrepFee
			,   vba1.EFilingFee
			,   vba1.SystemHold
			,   vba1.[Hidden]
            ,   vba1.NetTranFee
			,	vba1.CPTSAdminFee
			,	vba1.EFFee
			,	vba1.NetEFFee
			,	vba1.CPTSAdminEFFee
			,	vba1.EFFeeAll
			,   vba1.TechFee
			,   vba1.NetTechFee
			,   vba1.CPTSAdminTechFee
			,   vba1.SuperSBid 
			,	row_number() over ( partition by vba1.efin, vba1.bankId, vba1.Delivered order by vba1.BankAppId desc) AS 'RowNumber' 
			from
				dbo.vwBankApplication vba1
			where
				vba1.Delivered = 1
		) vba
	where
		vba.RowNumber = 1








GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[25] 4[3] 2[54] 3) )"
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
      Begin ColumnWidths = 9
         Width = 284
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwLatestSubmittedApplication';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwLatestSubmittedApplication';

