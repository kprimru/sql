USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[KGS_CLIENT_SELECT]
	@LIST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @XML = CAST(@LIST AS XML)

		SELECT ClientID, ClientFullName, CA_STR, CA_FULL
		FROM
			(
				SELECT
					c.value('(.)', 'INT') AS CL_ID
				FROM @xml.nodes('/LIST/ITEM') AS a(c)
			) AS a
			INNER JOIN dbo.ClientTable b ON a.CL_ID = b.ClientID
			INNER JOIN dbo.ClientAddressView c ON c.CA_ID_CLIENT = b.ClientID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[KGS_CLIENT_SELECT] TO rl_kgs_complect_calc;
GO