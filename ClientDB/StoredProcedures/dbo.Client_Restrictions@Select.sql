USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Client:Restrictions@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Client:Restrictions@Select]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[Client:Restrictions@Select]
    @Client_Id  Int
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
		    T.[Id], T.[Name], CR.[Comment],
		    [Checked] = Cast(CASE WHEN CR.[Id] IS NULL THEN 0 ELSE 1 END AS Bit)
		FROM [dbo].[Clients:Restrictions->Types]    AS T
		LEFT JOIN [dbo].[Clients:Restrictions]      AS CR   ON T.[Id] = CR.[Type_Id]
		                                                    AND CR.[Client_Id] = @Client_Id
		ORDER BY CR.[Type_Id]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Client:Restrictions@Select] TO rl_client_card;
GO
