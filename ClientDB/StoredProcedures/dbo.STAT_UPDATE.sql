USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STAT_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STAT_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STAT_UPDATE]
	@DATE	VARCHAR(20),
	@SYS	VARCHAR(20),
	@IB		VARCHAR(20),
	@DOCS	VARCHAR(20)
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

		DECLARE @DT SMALLDATETIME
		DECLARE @DC	INT

		SET @DT = CONVERT(SMALLDATETIME, @DATE, 112)
		SET @DC = CONVERT(INT, @DOCS)

		IF NOT EXISTS
			(
				SELECT *
				FROM
					dbo.StatisticTable a
					INNER JOIN dbo.InfoBankTable b ON a.InfoBankID = b.InfoBankID
					INNER JOIN dbo.SystemBankTable c ON c.InfoBankID = b.InfoBankID
					INNER JOIN dbo.SystemTable d ON d.SystemID = c.SystemID
				WHERE a.StatisticDate = @DT
					AND a.Docs = @DC AND SystemBaseName = @SYS
					AND InfoBankName = @IB
			)
			INSERT INTO dbo.StatisticTable (StatisticDate, InfoBankID, Docs)
				SELECT @DT, b.InfoBankID, @DC
				FROM
					dbo.InfoBankTable b
					INNER JOIN dbo.SystemBankTable c ON c.InfoBankID = b.InfoBankID
					INNER JOIN dbo.SystemTable d ON d.SystemID = c.SystemID
				WHERE SystemBaseName = @SYS
					AND InfoBankName = @IB

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STAT_UPDATE] TO rl_stat_import;
GO
