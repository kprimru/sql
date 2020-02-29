USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[EMAIL_PROCESS]
	@INPT NVARCHAR(MAX)
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

		SELECT EMAIL AS [Электронный адрес], ClientFullName AS [Клиент], ManagerName AS [Руководитель], ServiceName AS [СИ]
		FROM
			(
				SELECT EMAIL, 
					(
						SELECT TOP 1 ClientID
						FROM dbo.ClientEmailView
						WHERE EMAIL = ClientEMail
					) AS ID_CLIENT
				FROM
					(
						SELECT REPLACE(Item, CHAR(13), '') AS EMAIL
						FROM dbo.GET_STRING_TABLE_FROM_LIST(@INPT, CHAR(10))
					) AS a
			) AS a
			LEFT OUTER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = ID_CLIENT
		ORDER BY ManagerName, ServiceName, ClientFullName, EMAIL
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
