USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[VERIFY_DEFAULT_GET]
	@clientid INT,
	@date SMALLDATETIME
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

		SELECT 
			ORG_ID, ORG_SHORT_NAME, dbo.GET_SETTING('ORG_BUH') AS BUH_NAME,
			CL_FULL_NAME, 
			(
				SELECT SUM(SL_REST)
				FROM 
					(
						SELECT 
							ISNULL((
								SELECT TOP 1 SL_REST
								FROM dbo.SaldoTable b
								WHERE SL_ID_CLIENT = @clientid
									AND a.SL_ID_DISTR = b.SL_ID_DISTR
									AND SL_DATE < @date
								ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
								), 0) AS SL_REST
						FROM 
							(
								SELECT DISTINCT SL_ID_DISTR
								FROM dbo.SaldoTable
								WHERE SL_ID_CLIENT = @clientid
							) AS a
					) AS O_O
			) AS SL_REST
		FROM 
			dbo.ClientTable LEFT OUTER JOIN
			dbo.OrganizationTable ON CL_ID_ORG = ORG_ID
		WHERE CL_ID = @clientid
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
