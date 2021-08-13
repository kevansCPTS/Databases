﻿





CREATE VIEW [dbo].[vwLatestApplicationResponse]
AS
SELECT        dbo.vwBankApplication.AccountID, dbo.vwBankApplication.UserID, dbo.vwBankApplication.Efin, dbo.vwBankApplication.EfinID, dbo.vwBankApplication.Bank, 
                         dbo.vwBankApplication.BankID, dbo.vwBankApplication.BankAppID, dbo.vwBankApplication.Delivered, dbo.vwBankApplication.Sent, 
                         dbo.vwBankApplication.DeliveredDate, dbo.vwBankApplication.SentDate, dbo.vwBankApplication.Deleted, dbo.vwBankApplication.UpdatedDate, 
                         dbo.vwBankApplication.SubmittedRecordType, dbo.vwBankApplication.Master, dbo.vwBankApplication.EIN, dbo.vwBankApplication.EFINHolderSSN, 
                         dbo.vwBankApplication.EFINHolderFirstName, dbo.vwBankApplication.EFINHolderLastName, dbo.vwBankApplication.EFINHolderDOB, 
                         dbo.vwBankApplication.Company, dbo.vwBankApplication.Address, dbo.vwBankApplication.City, dbo.vwBankApplication.State, dbo.vwBankApplication.Zip, 
                         dbo.vwBankApplication.Phone, dbo.vwBankApplication.AlternatePhone, dbo.vwBankApplication.Fax, dbo.vwBankApplication.Email, 
                         dbo.vwBankApplication.FeeRoutingNumber, dbo.vwBankApplication.FeeAccountNumber, dbo.vwBankApplication.FeeAccountType, 
                         dbo.vwBankApplication.PEITechFee, dbo.vwBankApplication.PEIRALTransmitterFee, dbo.vwBankApplication.EROTranFee, dbo.vwBankApplication.EROBankFee, 
                         dbo.vwBankApplication.SBPrepFee, dbo.vwBankApplication.Roll, dbo.vwBankApplication.EfinStatus, dbo.vwBankApplication.ErrorCode, 
                         dbo.vwBankApplication.EfinProduct, dbo.vwBankApplication.ErrorDescription, dbo.vwBankApplication.Registered, dbo.vwBankApplication.RegisteredDescription, 
                         dbo.vwBankApplication.DistributorId, dbo.vwBankApplication.CompanyId, dbo.vwBankApplication.LocationId, dbo.vwBankApplication.CheckName, 
                         dbo.vwBankApplication.SBFeeAll, dbo.vwBankApplication.HoldFlag, dbo.vwBankApplication.RacsOnly, dbo.vwBankApplication.SBName, 
                         dbo.vwBankApplication.AllowMultipleBanks, dbo.vwBankApplication.LockedAtBank, dbo.vwBankApplication.SelectedBank, 
                         dbo.vwBankApplication.SelectedBankName, dbo.vwBankApplication.SCOStatus, dbo.vwBankApplication.DocPrepFee, 
						 dbo.vwBankApplication.EFilingFee, dbo.vwBankApplication.SystemHold, dbo.vwBankApplication.Hidden,
						 dbo.vwBankApplication.NetTranFee, dbo.vwBankApplication.CPTSAdminFee, dbo.vwBankApplication.EFFee, dbo.vwBankApplication.NetEFFee, 
						 dbo.vwBankApplication.CPTSAdminEFFee, dbo.vwBankApplication.EFFeeAll, dbo.vwBankApplication.TechFee, dbo.vwBankApplication.NetTechFee, 
             dbo.vwBankApplication.CPTSAdminTechFee, dbo.vwBankApplication.SuperSBid 

FROM            dbo.vwBankApplication WITH (nolock) INNER JOIN
                             (SELECT        Efin, BankCode, MAX(BankAppID) AS BankAppID
                               FROM            dbo.efin_regr WITH (nolock)
                               GROUP BY Efin, BankCode) AS [#LatestResponse] ON dbo.vwBankApplication.BankAppID = [#LatestResponse].BankAppID AND 
                         dbo.vwBankApplication.BankID = [#LatestResponse].BankCode





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[32] 4[4] 2[46] 3) )"
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
         Top = -192
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
         Begin Table = "#LatestResponse"
            Begin Extent = 
               Top = 198
               Left = 38
               Bottom = 310
               Right = 208
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1755
         Alias = 900
         Table = 2235
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwLatestApplicationResponse';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwLatestApplicationResponse';

