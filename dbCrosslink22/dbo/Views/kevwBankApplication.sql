

/**
This is the generic query which will return every application and it's latest 
bank response (if there is one).
*/
create VIEW [dbo].[kevwBankApplication]
AS
SELECT     dbo.efin.Account AS AccountID,
           dbo.efin.UserID,
		   dbo.efin.Efin,
		   [#Apps].EfinID,
		   [#Apps].Bank,
		   [#Apps].BankID,
		   [#Apps].BankAppID,
		   [#Apps].Delivered,
		   [#Apps].Sent, 
           [#Apps].DeliveredDate,
		   [#Apps].SentDate,
		   [#Apps].Deleted,
		   [#Apps].UpdatedDate,
		   [#Apps].SubmittedRecordType,
		   [#Apps].Master,
		   [#Apps].EIN,
		   [#Apps].EFINHolderSSN, 
           [#Apps].EFINHolderFirstName,
		   [#Apps].EFINHolderLastName,
		   [#Apps].EFINHolderDOB,
		   [#Apps].Company,
		   [#Apps].Address,
		   [#Apps].City,
		   [#Apps].State,
		   [#Apps].Zip, 
           [#Apps].Phone,
		   [#Apps].AlternatePhone,
		   [#Apps].Fax,
		   [#Apps].Email,
		   [#Apps].FeeRoutingNumber,
		   [#Apps].FeeAccountNumber,
		   [#Apps].FeeAccountType,
		   [#Apps].FeeAccountName, 
           [#Apps].PEITechFee,
		   [#Apps].PEIRALTransmitterFee,
		   [#Apps].EROTranFee,
		   (CASE WHEN #Apps.BankID = 'F' THEN efin.EROBankFee ELSE 0 END) AS EROBankFee, 
           [#Apps].SBPrepFee,
		   [#Apps].Roll,
		   efin_regr_1.EfinStatus,
		   efin_regr_1.EfinError AS ErrorCode,
		   efin_regr_1.EfinProduct, 
           (CASE WHEN #Apps.BankID = 'A' THEN efin_regr_1.ErrorDescription ELSE dbo.ltblBankRegRejects.RejectDescription END) AS ErrorDescription, 
           (CASE WHEN BankStatus.Registered IS NOT NULL THEN BankStatus.Registered ELSE (CASE WHEN #Apps.Delivered = 1 THEN 'P' ELSE 'U' END) END) AS Registered,
		   StatusDescription.Description AS RegisteredDescription,
		   dbo.efin.DistributorId,
		   dbo.efin.CompanyId,
		   dbo.efin.LocationId,
		   dbo.efin.CheckName, 
           dbo.efin.SBFeeAll,
		   ISNULL(dbo.efin.HoldFlag, 'N') AS HoldFlag,
		   (CASE WHEN [#Apps].BankID = 'R' AND efin_regr_1.EFINProduct = 'A' THEN 'N' ELSE 'Y' END) AS RacsOnly,
		   dbCrosslinkGlobal.dbo.customer.SBName,
		   dbo.efin.AllowMultipleBanks,
		   BankStatus.LockedAtBank,
		   dbo.efin.SelectedBank, 
           SelectedBank.BankName AS SelectedBankName,
		   dbo.efin.SCOStatus,
		   DocPrepFee,
		   EFilingFee,
		   SystemHold,
		   efin_regr_1.EfinBankFee,
		   efin_regr_1.EfinCompliance,
		   efin_regr_1.EfinCard,
		   efin_regr_1.EfinPrint,
		   efin_regr_1.EfinProduct2,
           [#Apps].[Hidden]
FROM         dbo.efin INNER JOIN
                          (SELECT     EfinID,
									  UserID,
						              'TPG' AS Bank,
						              'S' AS BankID,
									  SBTPG_BankAppID AS BankAppID,
									  Delivered,
									  Sent,
									  DeliveredDate,
									  SentDate,
									  Deleted,
									  UpdatedDate, 
                                      SubmittedRecordType,
									  Master,
									  (CASE WHEN IsNumeric(OwnersEIN) = 1 THEN OwnersEIN ELSE 0 END) AS EIN,
									  OwnersSSN AS EFINHolderSSN, 
                                      OwnersFirstName AS EFINHolderFirstName,
									  OwnersLastName AS EFINHolderLastName,
									  OwnersDateOfBirth AS EFINHolderDOB, 
                                      CompanyName AS Company,
									  OfficeAddress AS Address,
									  OfficeCity AS City,
									  OfficeState AS State,
									  OfficeZipCode AS Zip,
									  OfficePhoneNumber AS Phone, 
                                      OwnersPhoneNumber AS AlternatePhone,
									  OfficeFaxNumber AS Fax,
									  ManagersEmailAddress AS Email,
									  FeeRoutingNumber,
									  FeeAccountNumber, 
                                      FeeAccountType,
									  '' as FeeAccountName,
									  PEITechFee,
									  PEIRALTransmitterFee,
									  EROTranFee,
									  SBPrepFee,
									  Roll,
									  NULL AS DistributorId,
									  NULL AS CompanyId,
									  NULL AS LocationId,
									  DocPrepFee,
									  null as EFilingFee,
									  SystemHold,
                                      [Hidden]
                            FROM          dbo.SBTPG_BankApp
                            UNION
							SELECT     EfinID,
  									   UserID,
							           'TPGW' AS Bank,
									   'W' AS BankID,
									    SBTPGW_BankAppID AS BankAppID,
										Delivered,
										Sent,
										DeliveredDate,
										SentDate,
										Deleted,
										UpdatedDate, 
                                        SubmittedRecordType,
										Master,
										(CASE WHEN IsNumeric(OwnersEIN) = 1 THEN OwnersEIN ELSE 0 END) AS EIN,
										OwnersSSN AS EFINHolderSSN, 
                                        OwnersFirstName AS EFINHolderFirstName,
										OwnersLastName AS EFINHolderLastName,
										OwnersDateOfBirth AS EFINHolderDOB, 
                                        CompanyName AS Company,
										OfficeAddress AS Address,
										OfficeCity AS City,
										OfficeState AS State,
										OfficeZipCode AS Zip,
										OfficePhoneNumber AS Phone, 
                                        OwnersPhoneNumber AS AlternatePhone,
										OfficeFaxNumber AS Fax,
										ManagersEmailAddress AS Email,
										FeeRoutingNumber,
										FeeAccountNumber, 
                                        FeeAccountType,
										'' as FeeAccountName,
										PEITechFee,
										PEIRALTransmitterFee,
										EROTranFee,
										SBPrepFee,
										Roll,
										NULL AS DistributorId,
										NULL AS CompanyId,
										NULL AS LocationId,
										DocPrepFee,
										null as EFilingFee,
										SystemHold,
                                        [Hidden]
                            FROM        dbo.SBTPGW_BankApp
                            UNION
							SELECT     dbo.Republic_BankApp.EfinID,
									   UserID,
							           'Republic' AS Bank,
									   'R' AS BankID,
									   dbo.Republic_BankApp.Republic_BankAppID AS BankAppID,
									   dbo.Republic_BankApp.Delivered, 
                                       dbo.Republic_BankApp.Sent,
									   dbo.Republic_BankApp.DeliveredDate,
									   dbo.Republic_BankApp.SentDate,
									   dbo.Republic_BankApp.Deleted, 
                                       dbo.Republic_BankApp.UpdatedDate,
									   dbo.Republic_BankApp.SubmittedRecordType,
									   dbo.Republic_BankApp.Master,
									   NULL AS EIN, 
                                       dbo.Republic_BankApp.EfinOwnerSSN AS EFINHolderSSN,
									   dbo.Republic_BankApp.EfinOwnerFirstName AS EFINHolderFirstName, 
                                       dbo.Republic_BankApp.EfinOwnerLastName AS EFINHolderLastName,
									   dbo.Republic_BankApp.EfinOwnerDOB AS EFINHolderDOB, 
                                       dbo.Republic_BankApp.OfficeName AS Company,
									   dbo.Republic_BankApp.OfficePhysicalStreet AS Address, 
                                       dbo.Republic_BankApp.OfficePhysicalCity AS City,
									   dbo.Republic_BankApp.OfficePhysicalState AS State, 
                                       dbo.Republic_BankApp.OfficePhysicalZip AS Zip,
									   dbo.Republic_BankApp.OfficePhoneNumber AS Phone,
									   dbo.Republic_BankApp.CellPhoneNumber AS AlternatePhone,
									   dbo.Republic_BankApp.FaxNumber AS Fax, 
                                       dbo.Republic_BankApp.EmailAddress AS Email,
									   dbo.Republic_BankApp.FeeRoutingNumber,
									   dbo.Republic_BankApp.FeeAccountNumber, 
                                       dbo.Republic_BankApp.FeeAccountType,
									   dbo.Republic_BankApp.FeeAccountName,
									   dbo.Republic_BankApp.PEITechFee,
									   dbo.Republic_BankApp.PEIRALTransmitterFee, 
                                       dbo.Republic_BankApp.EROTranFee,
									   dbo.Republic_BankApp.SBPrepFee AS SBPrepFee,
									   dbo.Republic_BankApp.Roll,
									   NULL AS DistributorId,
									   NULL AS CompanyId,
									   NULL AS LocationId,
									   null as DocPrepFee,
									   null as EFilingFee,
									   SystemHold,
                                       [Hidden]
                            FROM       dbo.Republic_BankApp 
                            UNION
							SELECT     dbo.Refundo_BankApp.EfinID,
									   UserID,
							           'Refundo' AS Bank,
									   'F' AS BankID,
									   dbo.Refundo_BankApp.Refundo_BankAppID AS BankAppID,
									   dbo.Refundo_BankApp.Delivered, 
                                       dbo.Refundo_BankApp.Sent,
									   dbo.Refundo_BankApp.DeliveredDate,
									   dbo.Refundo_BankApp.SentDate,
									   dbo.Refundo_BankApp.Deleted, 
                                       dbo.Refundo_BankApp.UpdatedDate,
									   dbo.Refundo_BankApp.SubmittedRecordType,
									   dbo.Refundo_BankApp.Master,
									   NULL AS EIN, 
                                       dbo.Refundo_BankApp.EfinOwnerSSN AS EFINHolderSSN,
									   dbo.Refundo_BankApp.EfinOwnerFirstName AS EFINHolderFirstName, 
                                       dbo.Refundo_BankApp.EfinOwnerLastName AS EFINHolderLastName,
									   dbo.Refundo_BankApp.EfinOwnerDOB AS EFINHolderDOB, 
                                       dbo.Refundo_BankApp.OfficeName AS Company,
									   dbo.Refundo_BankApp.OfficePhysicalStreet AS Address, 
                                       dbo.Refundo_BankApp.OfficePhysicalCity AS City,
									   dbo.Refundo_BankApp.OfficePhysicalState AS State, 
                                       dbo.Refundo_BankApp.OfficePhysicalZip AS Zip,
									   dbo.Refundo_BankApp.OfficePhoneNumber AS Phone,
									   dbo.Refundo_BankApp.CellPhoneNumber AS AlternatePhone,
									   dbo.Refundo_BankApp.FaxNumber AS Fax, 
                                       dbo.Refundo_BankApp.EmailAddress AS Email,
									   dbo.Refundo_BankApp.FeeRoutingNumber,
									   dbo.Refundo_BankApp.FeeAccountNumber, 
                                       dbo.Refundo_BankApp.FeeAccountType,
									   '' as FeeAccountName,
									   dbo.Refundo_BankApp.PEITechFee,
									   dbo.Refundo_BankApp.PEIRALTransmitterFee, 
                                       dbo.Refundo_BankApp.EROTranFee,
									   dbo.Refundo_BankApp.SBPrepFee AS SBPrepFee,
									   dbo.Refundo_BankApp.Roll,
									   NULL AS DistributorId,
									   NULL AS CompanyId,
									   NULL AS LocationId,
									   null as DocPrepFee,
									   null as EFilingFee,
									   SystemHold,
                                       [Hidden]
                           FROM       dbo.Refundo_BankApp 
                            UNION
                            SELECT     dbo.Refund_Advantage_BankApp.EfinID,
									   UserID,
							           'Refund Advantage' AS Bank,
									   'V' AS BankID, 
                                       dbo.Refund_Advantage_BankApp.Refund_Advantage_BankAppID AS BankAppID,
									   dbo.Refund_Advantage_BankApp.Delivered, 
                                       dbo.Refund_Advantage_BankApp.Sent,
									   dbo.Refund_Advantage_BankApp.DeliveredDate,
									   dbo.Refund_Advantage_BankApp.SentDate, 
                                       dbo.Refund_Advantage_BankApp.Deleted,
									   dbo.Refund_Advantage_BankApp.UpdatedDate,
									   ' ' AS SubmittedRecordType, 
                                       dbo.Refund_Advantage_BankApp.Master,
									   0 AS EIN,
									   rbo.SSN AS EFINHolderSSN, 
                                       rbo.FirstName AS EFINHolderFirstName, 
                                       rbo.LastName AS EFINHolderLastName,
									   rbo.DOB AS EFINHolderDOB, 
                                       dbo.Refund_Advantage_BankApp.OfficeName AS Company,
									   dbo.Refund_Advantage_BankApp.OfficeAddressStreet AS Address, 
                                       dbo.Refund_Advantage_BankApp.OfficeAddressCity AS City,
									   dbo.Refund_Advantage_BankApp.OfficeAddressState AS State, 
                                       dbo.Refund_Advantage_BankApp.OfficeAddressZip AS Zip,
									   dbo.Refund_Advantage_BankApp.OfficePhone AS Phone,
									   '' AS AlternatePhone, 
                                       dbo.Refund_Advantage_BankApp.OfficeFax AS Fax,
									   '' AS Email,
									   dbo.Refund_Advantage_BankApp.FeeRoutingNumber, 
                                       dbo.Refund_Advantage_BankApp.FeeAccountNumber,
									   dbo.Refund_Advantage_BankApp.FeeAccountType,
									   '' as FeeAccountName,
									   dbo.Refund_Advantage_BankApp.PEITechFee, 
                                       dbo.Refund_Advantage_BankApp.PEIRALTransmitterFee,
									   dbo.Refund_Advantage_BankApp.EROTranFee, 
                                       dbo.Refund_Advantage_BankApp.SBFee AS SBPrepFee,
									   dbo.Refund_Advantage_BankApp.Roll,
									   NULL AS DistributorId,
									   NULL AS CompanyId,
									   NULL AS LocationId,
									   null as DocPrepFee,
									   EFilingFee,
									   SystemHold,
                                       [Hidden]
                            FROM       dbo.Refund_Advantage_BankApp
							           LEFT OUTER JOIN (
															select 
																rbo1.Refund_Advantage_BankAppID
															,	rbo1.Refund_Advantage_Business_OwnerID
															,	rbo1.SSN
															,	rbo1.FirstName
															,	rbo1.LastName
															,	rbo1.DOB
															from
																(
																	select 
																		rbo2.Refund_Advantage_BankAppID
																	,	rbo2.Refund_Advantage_Business_OwnerID
																	,	rbo2.SSN
																	,	rbo2.FirstName
																	,	rbo2.LastName
																	,	rbo2.DOB
																	,	row_number() over ( partition by rbo2.Refund_Advantage_BankAppID order by rbo2.PercentOwned desc) AS 'RowNumber' 
																	from
																		dbo.Refund_Advantage_Business_Owner rbo2	
																) rbo1
															where
																rbo1.RowNumber = 1
													   ) rbo on dbo.Refund_Advantage_BankApp.Refund_Advantage_BankAppID = rbo.Refund_Advantage_BankAppID


											)
											AS [#Apps] ON dbo.efin.EfinID = [#Apps].EfinID 
											and dbo.efin.UserID = [#Apps].UserID
									   LEFT OUTER JOIN
                                            (SELECT BankCode, BankAppID, MAX(rowID) AS RegrRowID
                                                FROM dbo.efin_regr
                                                GROUP BY BankCode, BankAppID) AS [#LASTRESPONSE] ON [#LASTRESPONSE].BankCode = [#Apps].BankID
							                        AND [#LASTRESPONSE].BankAppID = [#Apps].BankAppID
									 LEFT OUTER JOIN
                                         dbo.efin_regr AS efin_regr_1 ON [#LASTRESPONSE].RegrRowID = efin_regr_1.rowID
									 LEFT OUTER JOIN
									     dbo.ltblBankRegRejects ON efin_regr_1.EfinError = dbo.ltblBankRegRejects.RejectCode AND efin_regr_1.BankCode = dbo.ltblBankRegRejects.Bank
									 LEFT OUTER JOIN
                                         dbo.ltblBankRegistrationStatus AS BankStatus ON BankStatus.BankID = efin_regr_1.BankCode AND BankStatus.EFINStatus = efin_regr_1.EfinStatus
									 LEFT OUTER JOIN
                                         dbo.ltblRegistrationStatusDescription AS StatusDescription ON StatusDescription.Registered = (CASE WHEN BankStatus.Registered IS NOT NULL 
                                         THEN BankStatus.Registered ELSE (CASE WHEN #Apps.Delivered = 1 THEN 'P' ELSE 'U' END) END)
									 LEFT OUTER JOIN
                                         dbCrosslinkGlobal.dbo.customer ON dbCrosslinkGlobal.dbo.customer.account = dbo.efin.Account
									 LEFT OUTER JOIN
                                         dbo.EFINBank AS SelectedBank ON SelectedBank.EFINBankID = dbo.efin.SelectedBank
										 



