USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_EMAIL_SELECT]
	@CLIENT	INT
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

		SELECT DISTINCT ML
		FROM
			(
				SELECT ClientEMail AS ML
				FROM dbo.ClientTable
				WHERE ClientID = @CLIENT
					AND STATUS = 1
				
				UNION ALL
				
				SELECT DISTINCT CP_EMAIL
				FROM 
					dbo.ClientPersonal
					INNER JOIN dbo.ClientTable ON ClientID = CP_ID_CLIENT
				WHERE CP_ID_CLIENT = @CLIENT
					AND STATUS = 1
				
				UNION ALL
				
				SELECT DISTINCT EMAIL
				FROM dbo.ClientDelivery
				WHERE ID_CLIENT = @CLIENT
					
				UNION ALL
				
				SELECT DISTINCT EMAIL
				FROM dbo.ClientDutyTable
				WHERE ClientID = @CLIENT
					AND STATUS = 1
			) AS o_O
		WHERE ISNULL(ML, '') <> ''
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
