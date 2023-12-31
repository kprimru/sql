USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANKS_CREATE]
	@SYS_LIST				VARCHAR(MAX),
	@DISTR_TYPE_LIST		VARCHAR(MAX),
	@BANK_REQ_LIST				VARCHAR(MAX)
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
		FROM dbo.GET_STRING_TABLE_FROM_LIST(@BANK_REQ_LIST, ',')

		DELETE FROM dbo.SystemsBanks
		WHERE	System_Id IN (SELECT System_Id FROM @s) AND
				DistrType_Id IN (SELECT DistrType_Id FROM @d)

		INSERT INTO dbo.SystemsBanks(System_Id, DistrType_Id, InfoBank_Id, Required, Start)
		SELECT
			s.System_Id, d.DistrType_Id,
			SUBSTRING(ib.InfoBank_Id, 1, CHARINDEX('-', ib.InfoBank_Id)-1),
			SUBSTRING(ib.InfoBank_Id, CHARINDEX('-', ib.InfoBank_Id)+1, LEN(ib.InfoBank_Id)),
			GETDATE()
		FROM @s s
		CROSS APPLY @d d
		CROSS APPLY @ib ib

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANKS_CREATE] TO rl_system_bank_i;
GO
