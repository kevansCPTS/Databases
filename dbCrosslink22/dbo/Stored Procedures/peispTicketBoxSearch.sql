CREATE PROCEDURE [dbo].[peispTicketBoxSearch]
@boxID int = null,
@userID int = null

AS

SELECT 
	TicketID,
	CommunicationID,
	DisplayText, 
	CommDate, 
	Header,
	ContactData,
	ApplicationID,
	Description,
	Category,
	SubCategory
FROM 
	(
	/** This portion grabs untouched communications for the the given User or Ticket box */
	SELECT 
		null AS TicketID,
		CommunicationID,
		'Unprocessed' AS DisplayText,
		CreationDate AS CommDate,
		Subject AS Header,
		(CASE WHEN UserID is not null THEN 'UserID: ' + CAST(UserID AS varchar(10))
			ELSE ContactInfo END) AS ContactData,
		SRC.ApplicationID,
		Convert(varchar(1000), Description) Description,
		null AS Category,
		null AS SubCategory

	FROM Communication C 
		LEFT JOIN TicketSource SRC ON C.Source = SRC.SourceCode
	WHERE ((@boxID is null) OR (TechID = @boxID)) 
		AND ((@userID is null) OR (UserID = @userID)) 
		AND TicketID is null
		AND IgnoreCode is null

	UNION	

	/** This portion grabs Tickets.  Resolved Tickets and Suggestions are ignored unless the query
	      is by UserID */
	SELECT 
		T.TicketID,
		null AS CommunicationID,
		TS.DisplayText,
		UserModified AS CommDate,
		T.Title AS Header,
		(CASE WHEN UserID is not null THEN 'UserID: ' + CAST(UserID AS varchar(10))
			ELSE 'Unknown User' END) AS ContactData,
		P.ApplicationID,
		T.Description,
		TC.Description Category,
		TSC.Description SubCategory
	FROM Ticket T
		INNER JOIN TicketStatus TS ON TS.StatusCode = T.Status
		LEFT JOIN Product P ON P.ProductID = T.ProductID
		LEFT JOIN TicketCategory TC ON TC.CategoryID = T.CategoryID
		LEFT JOIN TicketSubCategory TSC ON TSC.SubCategoryID = T.SubCategoryID
	WHERE ((@boxID is null) OR (TechID = @boxID)) 
		AND ((@userID is null AND T.ResolutionDate is null AND T.ISSuggestion = 0) 
			OR (@userID is not null AND UserID = @userID)) 
/*
	UNION

	SELECT 
		T.TicketID,
		null AS CommunicationID,
		TS.DisplayText,
		Convert(char(10), UserModified, 101) + ' ' + 
			Convert(char(5), UserModified, 14) AS CommDate,
		T.Title AS Header,
		(CASE WHEN UserID is not null THEN 'UserID: ' + CAST(UserID AS varchar(10))
			ELSE 'Unknown User' END) AS ContactData,
		P.ApplicationID
	FROM Ticket T
		INNER JOIN TicketStatus TS ON TS.StatusCode = T.Status
		LEFT JOIN Product P ON P.ProductID = T.ProductID
	WHERE ((@userID is not null) AND (UserID = @userID)) 
		AND ResolutionDate is not null
*/
	)
AS BoxTickets
ORDER BY (Convert(datetime, CommDate)) DESC


