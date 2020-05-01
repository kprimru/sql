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

ALTER PROCEDURE [dbo].[TO_DEFAULT_GET]
	@clientid INT
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

		SELECT TOP 1
			CL_FULL_NAME AS TO_NAME, CL_INN,
			(
				SELECT MAX(TO_NUM) + 1
				FROM dbo.TOTable			
			) AS TO_NUM,
			ST_NAME, ST_ID, CA_INDEX, CA_HOME,
			CASE 
				(
					SELECT COUNT(*)
					FROM dbo.TOTable
					WHERE TO_ID_CLIENT = @clientid
						AND TO_MAIN = 1
				)
				WHEN 0 THEN 1
				ELSE 0
			END AS TO_MAIN
		FROM 
			dbo.ClientTable LEFT OUTER JOIN
			dbo.ClientAddressTable ON CA_ID_CLIENT = CL_ID LEFT OUTER JOIN
			dbo.StreetTable ON ST_ID = CA_ID_STREET
		WHERE CL_ID = @clientid 
		ORDER BY CA_ID_TYPE DESC, ISNULL(ST_ID, 0) DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[TO_DEFAULT_GET] TO rl_to_r;
GO