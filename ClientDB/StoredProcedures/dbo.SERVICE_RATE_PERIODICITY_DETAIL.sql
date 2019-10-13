USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_PERIODICITY_DETAIL]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX),
	@ERROR		BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @WEEK TABLE (WEEK_ID SMALLINT, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

	INSERT INTO @WEEK(WEEK_ID, WBEGIN, WEND)
		SELECT WEEK_ID, WBEGIN, WEND 
		FROM dbo.WeekDates(@BEGIN, @END)


	SELECT 
		ClientID, ClientFullName, UpdateLost,
		CASE
			WHEN UpdateLost IS NULL THEN 1
			ELSE 0
		END AS UpdateMatch,
		(
			SELECT CONVERT(VARCHAR(20), EventDate, 104) + ' ' + EventComment + CHAR(10)
			FROM EventTable z
			WHERE EventActive = 1 
				AND o_O.ClientID = z.ClientID
				AND EventDate BETWEEN @BEGIN AND @END
			ORDER BY EventDate FOR XML PATH('')
		) AS EventComment
	FROM 
		(
			SELECT 
				ClientID, ClientFullName, 
				REVERSE(STUFF(REVERSE((
						SELECT 'С ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + ', '
						FROM @WEEK
						WHERE  NOT EXISTS
							(
								SELECT *
								FROM 
									USR.USRIBDateView WITH(NOEXPAND)
								WHERE UD_ID_CLIENT = ClientID 
									AND UIU_DATE_S BETWEEN WBEGIN AND WEND
							)
						ORDER BY WEEK_ID FOR XML PATH('')
					)), 1, 2, '')) AS UpdateLost						
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID
			WHERE ClientServiceID = @SERVICE 
				AND STATUS = 1
				AND EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE a.ClientID = z.ID_CLIENT AND DistrTypeBaseCheck = 1 AND DS_REG = 0
					)
		) AS o_O
	WHERE (@ERROR = 0 OR UpdateLost IS NOT NULL)
	ORDER BY ClientFullName
END