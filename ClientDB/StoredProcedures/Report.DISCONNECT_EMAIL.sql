USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[DISCONNECT_EMAIL]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT DISTINCT 
			b.ClientFullName AS [Клиент], b.ServiceStatusName AS [Статус], a.ClientEMail AS [Email],
			(
				SELECT TOP 1 DisconnectDate
				FROM dbo.ClientDisconnectView z WITH(NOEXPAND)
				WHERE z.ClientID = b.ClientID
				ORDER BY DisconnectDate DESC
			) AS [Дата отключения]
		FROM 
			dbo.ClientEMailView a
			INNER JOIN dbo.ClientView b ON a.ClientID = b.ClientID
		WHERE ServiceStatusID <> 2
		ORDER BY ClientFullName
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
