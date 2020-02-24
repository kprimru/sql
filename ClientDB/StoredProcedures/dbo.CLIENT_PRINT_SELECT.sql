USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_PRINT_SELECT]
	@LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @CLIENT	TABLE(CL_ID INT PRIMARY KEY)	

		INSERT INTO @CLIENT
			SELECT ID
			FROM dbo.TableIDFromXML(@LIST)

		SELECT 
			a.ClientID, ClientFullName, ServiceName = ServiceName + ' (' + ManagerName + ')', CA_STR_PRNT AS ClientAdress, 
			ClientActivity, ClientDayBegin, ClientDayEnd, 
			ServiceTypeName,
			DinnerBegin, DinnerEnd,
			ClientNewsPaper, ClientMainBook, PayTypeName, 
			DayName, ServiceStart, ServiceTime,
			ClientNote, ClientEmail, ClientPlace,
			PrintServer =
				CASE
					WHEN EXISTS
					(
						SELECT *
						FROM USR.USRData
						CROSS APPLY
						(
							SELECT TOP 1 OS_NAME
							FROM USR.USRFile F
							INNER JOIN USR.USRFileTech T ON F.UF_ID = T.UF_ID
							INNER JOIN USR.OS ON OS_ID = T.UF_ID_OS
							INNER JOIN dbo.USRFileKindTable ON USRFileKindId = UF_ID_KIND
							WHERE USRFileKindName IN ('P', 'R', 'I')
								AND UF_ACTIVE = 1
								AND UD_ID = UF_ID_COMPLECT
							ORDER BY UF_CREATE DESC
						) o_O
						WHERE UD_ID_CLIENT = CL_ID
							AND 
							(
								OS_NAME LIKE '%Server%'
								OR
								OS_NAME LIKE '%Ñåðâåð%'
							)
					) THEN 'ÑÅÐÂÅÐÍÀß ÎÑ' 
					ELSE NULL END
		FROM 
			@CLIENT
			INNER JOIN dbo.ClientTable a ON CL_ID = a.ClientID
			INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
			INNER JOIN dbo.ManagerTable m ON m.ManagerID = b.ManagerID
			INNER JOIN dbo.ServiceTypeTable c ON a.ServiceTypeID = c.ServiceTypeID
			LEFT OUTER JOIN dbo.ClientAddressView f ON f.CA_ID_CLIENT = a.ClientID AND AT_REQUIRED = 1
			LEFT OUTER JOIN dbo.PayTypeTable d ON a.PayTypeID = d.PayTypeID
			LEFT OUTER JOIN dbo.DayTable e ON e.DayID = a.DayID
		ORDER BY ClientFullName, ClientID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
