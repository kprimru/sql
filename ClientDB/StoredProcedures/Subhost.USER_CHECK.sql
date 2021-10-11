USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[USER_CHECK]
	@LOGIN	NVARCHAR(128),
	@PASS	NVARCHAR(128),
	@IP		NVARCHAR(128) = NULL
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

		SELECT b.SH_ID, b.SH_REG
		FROM
			Subhost.Users a
			INNER JOIN dbo.Subhost b ON a.ID_SUBHOST = b.SH_ID
		WHERE a.NAME = @LOGIN AND a.PASS = @PASS

		IF @IP IS NOT NULL
			INSERT INTO Subhost.Session(LGN, IP)
				VALUES(@LOGIN, @IP)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[USER_CHECK] TO rl_web_subhost;
GO
