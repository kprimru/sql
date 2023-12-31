USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[CLIENT_DEFAULT_GET]
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

		SELECT (SELECT MAX(CL_NUM) + 1 FROM ClientTable) AS CL_NUM, ORG_ID, ORG_PSEDO, SH_ID, SH_SHORT_NAME, '������' AS CL_FOUND
		FROM
		(
		    SELECT TOP (1) ORG_ID, ORG_PSEDO
		    FROM dbo.OrganizationTable
		    ORDER BY ORG_ID
		) AS O,
		(
		    SELECT TOP (1) SH_ID, SH_SHORT_NAME
		    FROM dbo.SubhostTable
		    ORDER BY SH_ID
		) AS S;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DEFAULT_GET] TO rl_client_r;
GO
