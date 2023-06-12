USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_BANKS_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_BANKS_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANKS_GET]
	@SYS_LIST			NVARCHAR(MAX),
	@DISTR_TYPE_LIST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Systems	TABLE
	(
		System_Id	SmallInt Primary Key Clustered
	);

	DECLARE @DistrTypes TABLE
	(
		DistrType_Id	SmallInt Primary Key Clustered
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

		SELECT DISTINCT InfoBank_ID, InfoBankName, InfoBankShortName, Required, InfoBankOrder
		FROM dbo.SystemInfoBanksView	AS I WITH(NOEXPAND)
		INNER JOIN @Systems				AS S ON S.System_Id = I.System_Id
		INNER JOIN @DistrTypes			AS D ON D.DistrType_Id = I.DistrType_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANKS_GET] TO rl_system_bank_r;
GO
