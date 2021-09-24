USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANKS_ADD]
	@SYS_LIST				VARCHAR(MAX),
	@DISTR_TYPE_LIST		VARCHAR(MAX),
	@BANK_LIST				VARCHAR(MAX),
	@REQUIRE				BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Systems TABLE
	(
		System_Id		SmallInt Primary Key Clustered
	);

	DECLARE @DistrTypes	TABLE
	(
		DistrType_Id	SmallInt Primary Key Clustered
	);

	DECLARE @InfoBanks	TABLE
	(
		InfoBank_Id		SmallInt Primary Key Clustered
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Systems(System_Id)
		SELECT *
		FROM dbo.GET_STRING_TABLE_FROM_LIST(@SYS_LIST, ',')

		INSERT INTO @DistrTypes(DistrType_Id)
		SELECT *
		FROM dbo.GET_STRING_TABLE_FROM_LIST(@DISTR_TYPE_LIST, ',')

		INSERT INTO @InfoBanks(InfoBank_Id)
		SELECT *
		FROM dbo.GET_STRING_TABLE_FROM_LIST(@BANK_LIST, ',')


		INSERT INTO dbo.SystemsBanks(System_Id, DistrType_Id, InfoBank_Id, Required, Start)
		SELECT s.System_Id, d.DistrType_Id, ib.InfoBank_Id, @REQUIRE, GETDATE()
		FROM @Systems s
		CROSS APPLY @DistrTypes d
		CROSS APPLY @InfoBanks ib
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemsBanks sb
				WHERE	sb.System_Id = s.System_Id AND
						sb.DistrType_Id = d.DistrType_Id AND
						sb.InfoBank_Id = ib.InfoBank_Id
			);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANKS_ADD] TO rl_system_bank_i;
GO
