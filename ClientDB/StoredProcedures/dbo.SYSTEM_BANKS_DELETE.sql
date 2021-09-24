USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANKS_DELETE]
	@SYS_LIST				NVARCHAR(MAX),
	@DISTR_TYPE_LIST		NVARCHAR(MAX),
	@BANK_LIST				NVARCHAR(MAX)
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

		DECLARE @s	TABLE
		(
			System_Id	VARCHAR(5)
		)

		DECLARE @d	TABLE
		(
			DistrType_Id	VARCHAR(5)
		)

		DECLARE @ib	TABLE
		(
			InfoBank_Id	VARCHAR(5)
		)


		INSERT INTO @s(System_Id)
		SELECT *
		FROM dbo.GET_STRING_TABLE_FROM_LIST(@SYS_LIST, ',')

		INSERT INTO @d(DistrType_Id)
		SELECT *
		FROM dbo.GET_STRING_TABLE_FROM_LIST(@DISTR_TYPE_LIST, ',')

		INSERT INTO @ib(InfoBank_Id)
		SELECT *
		FROM dbo.GET_STRING_TABLE_FROM_LIST(@BANK_LIST, ',')

		DELETE FROM dbo.SystemsBanks
		WHERE	System_Id IN (SELECT System_Id FROM @s) AND
				DistrType_Id IN (SELECT DistrType_Id FROM @d) AND
				InfoBank_Id IN (SELECT InfoBank_Id FROM @ib)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH


END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANKS_DELETE] TO rl_system_bank_d;
GO
