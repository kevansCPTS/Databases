





CREATE VIEW [dbo].[vwPortalApp]
AS
SELECT     efin.Account AS AccountID, efin.UserID, dbo.Refund_Advantage_BankApp.EfinID, 'Refund Advantage' AS Bank, 'V' AS BankID, 
                      dbo.Refund_Advantage_BankApp.Refund_Advantage_BankAppID AS BankAppID, dbo.Refund_Advantage_BankApp.Delivered, dbo.Refund_Advantage_BankApp.Sent, dbo.Refund_Advantage_BankApp.DeliveredDate, 
                      dbo.Refund_Advantage_BankApp.SentDate, dbo.Refund_Advantage_BankApp.Deleted, Refund_Advantage_BankApp.updateddate AS UpdatedDate, Refund_Advantage_BankApp.SystemHold
FROM         dbo.Refund_Advantage_BankApp INNER JOIN
                      dbo.efin ON efin.EfinID = dbo.Refund_Advantage_BankApp.EfinID
					  AND dbo.Refund_Advantage_BankApp.UserID = dbo.efin.userId
UNION
SELECT     TOP (100) PERCENT efin_1.Account AS AccountID, efin_1.UserID, dbo.SBTPG_BankApp.EfinID, 'TPG' AS Bank, 'S' AS BankID, 
                      dbo.SBTPG_BankApp.SBTPG_BankAppID AS BankAppID, dbo.SBTPG_BankApp.Delivered, dbo.SBTPG_BankApp.Sent, dbo.SBTPG_BankApp.DeliveredDate, 
                      dbo.SBTPG_BankApp.SentDate, dbo.SBTPG_BankApp.Deleted, dbo.SBTPG_BankApp.UpdatedDate, SBTPG_BankApp.SystemHold
FROM         dbo.SBTPG_BankApp INNER JOIN
                      dbo.efin AS efin_1 ON efin_1.EfinID = dbo.SBTPG_BankApp.EfinID
					  AND dbo.SBTPG_BankApp.UserID = efin_1.userId
WHERE				  dbo.SBTPG_BankApp.WorldAcceptance= 0
UNION
SELECT     TOP (100) PERCENT efin_1.Account AS AccountID, efin_1.UserID, dbo.SBTPGW_BankApp.EfinID, 'TPGW' AS Bank, 'W' AS BankID, 
                      dbo.SBTPGW_BankApp.SBTPGW_BankAppID AS BankAppID, dbo.SBTPGW_BankApp.Delivered, dbo.SBTPGW_BankApp.Sent, dbo.SBTPGW_BankApp.DeliveredDate, 
                      dbo.SBTPGW_BankApp.SentDate, dbo.SBTPGW_BankApp.Deleted, dbo.SBTPGW_BankApp.UpdatedDate, SBTPGW_BankApp.SystemHold
FROM         dbo.SBTPGW_BankApp INNER JOIN
                      dbo.efin AS efin_1 ON efin_1.EfinID = dbo.SBTPGW_BankApp.EfinID
					  AND dbo.SBTPGW_BankApp.UserID = efin_1.userId
UNION
SELECT     TOP (100) PERCENT efin_1.Account AS AccountID, efin_1.UserID, dbo.Republic_BankApp.EfinID, 'Republic' AS Bank, 'R' AS BankID, 
                      dbo.Republic_BankApp.Republic_BankAppID AS BankAppID, dbo.Republic_BankApp.Delivered, dbo.Republic_BankApp.Sent, dbo.Republic_BankApp.DeliveredDate, 
                      dbo.Republic_BankApp.SentDate, dbo.Republic_BankApp.Deleted, dbo.Republic_BankApp.UpdatedDate, Republic_BankApp.SystemHold
FROM         dbo.Republic_BankApp INNER JOIN
                      dbo.efin AS efin_1 ON efin_1.EfinID = dbo.Republic_BankApp.EfinID
					  AND dbo.Republic_BankApp.UserID = efin_1.userId
UNION
SELECT     TOP (100) PERCENT efin_1.Account AS AccountID, efin_1.UserID, dbo.Refundo_BankApp.EfinID, 'Refundo' AS Bank, 'F' AS BankID, 
                      dbo.Refundo_BankApp.Refundo_BankAppID AS BankAppID, dbo.Refundo_BankApp.Delivered, dbo.Refundo_BankApp.Sent, dbo.Refundo_BankApp.DeliveredDate, 
                      dbo.Refundo_BankApp.SentDate, dbo.Refundo_BankApp.Deleted, dbo.Refundo_BankApp.UpdatedDate, Refundo_BankApp.SystemHold
FROM         dbo.Refundo_BankApp INNER JOIN
                      dbo.efin AS efin_1 ON efin_1.EfinID = dbo.Refundo_BankApp.EfinID
					  AND dbo.Refundo_BankApp.UserID = efin_1.userId
UNION
SELECT     TOP (100) PERCENT efin_1.Account AS AccountID, efin_1.UserID, dbo.JTHF_BankApp.EfinID, 'JTHF' AS Bank, 'J' AS BankID, 
                      dbo.JTHF_BankApp.JTHF_BankAppID AS BankAppID, dbo.JTHF_BankApp.Delivered, dbo.JTHF_BankApp.Sent, dbo.JTHF_BankApp.DeliveredDate, 
                      dbo.JTHF_BankApp.SentDate, dbo.JTHF_BankApp.Deleted, dbo.JTHF_BankApp.UpdatedDate, JTHF_BankApp.SystemHold
FROM         dbo.JTHF_BankApp INNER JOIN
                      dbo.efin AS efin_1 ON efin_1.EfinID = dbo.JTHF_BankApp.EfinID
					  AND dbo.JTHF_BankApp.UserID = efin_1.userId
                      
/*
UNION SELECT     dbo.Refund_Advantage_BankApp. AS AccountID, dbo.efin.UserID, dbo.Refund_Advantage_BankApp.EfinID, 'Refund Advantage' AS Bank, 'V' AS BankID, dbo.Refund_Advantage_BankApp.Refund_Advantage_BankAppID AS BankAppID, 
                      dbo.Refund_Advantage_BankApp.Delivered, dbo.Refund_Advantage_BankApp.Sent, dbo.Refund_Advantage_BankApp.DeliveredDate, dbo.Refund_Advantage_BankApp.SentDate, dbo.Refund_Advantage_BankApp.Deleted, 
                      dbo.Refund_Advantage_BankApp.updateddate AS UpdatedDate
FROM         dbo.Refund_Advantage_BankApp INNER JOIN
                      dbo.efin ON dbo.efin.EfinID = dbo.Refund_Advantage_BankApp.EfinID
*/
ORDER BY EfinID, bank, bankappid






GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Configuration = "(H (4[30] 2[40] 3) )"
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
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 15
         Width = 284
         Width = 1170
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
         Column = 3345
         Alias = 1605
         Table = 1710
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwPortalApp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwPortalApp';

