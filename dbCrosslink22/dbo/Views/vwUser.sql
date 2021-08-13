CREATE VIEW [dbo].[vwUser]
AS
SELECT     [#temp].user_id, [#temp].account, [#temp].bank_id, [#temp].prep, [#temp].mast_efin, [#temp].hold_flag, [#temp].status, [#temp].passwd, [#temp].contact, 
                      [#temp].c_phone, [#temp].fax, [#temp].contacted_dt, [#temp].contacted_tm, [#temp].contacted_by, [#temp].result, [#temp].follow_up_dt, 
                      [#temp].follow_up_tm, [#temp].follow_up_by, [#temp].phone, [#temp].fname, [#temp].lname, [#temp].company, [#temp].addr1, [#temp].addr2, 
                      [#temp].city, [#temp].state, [#temp].zip, [#temp].edit_by, [#temp].edit_dt, [#temp].web_passwd, [#temp].email, [#temp].sb_id, 
                      [#temp].ral_transmitter_fee, [#temp].onboard_date, [#temp].AccessPassword, [#temp].hold_note, [#temp].hold_date, [#temp].hold_by, 
                      dbo.FranchiseChild.ParentUserID, dbo.FranchiseChild.ChildUserID, dbo.FranchiseOwner.UserID, dbo.FranchiseOwner.FranchiseName, 
                      dbo.FranchiseOwner.FranchiseSBFee, CAST((CASE WHEN [#temp].user_id = franchiseowner.userid THEN 1 ELSE 0 END) AS bit) 
                      AS isFranchiseOwner
FROM         dbCrosslinkGlobal.dbo.tblUser AS [#temp] LEFT OUTER JOIN
                      dbo.FranchiseChild ON [#temp].user_id = dbo.FranchiseChild.ChildUserID LEFT OUTER JOIN
                      dbo.FranchiseOwner ON [#temp].user_id = dbo.FranchiseOwner.UserID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[24] 2[29] 3) )"
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
         Begin Table = "FranchiseChild"
            Begin Extent = 
               Top = 6
               Left = 250
               Bottom = 91
               Right = 402
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FranchiseOwner"
            Begin Extent = 
               Top = 6
               Left = 440
               Bottom = 111
               Right = 684
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "#temp"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 212
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
      Begin ColumnWidths = 46
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
 ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'        Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwUser';

