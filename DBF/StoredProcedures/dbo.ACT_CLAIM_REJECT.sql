USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CLAIM_REJECT]
	@DATA	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
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

		DECLARE @XML XML

		SET @XML = CAST(@DATA AS XML)

		/*
		UPDATE a
		SET CALC_NOTE = REASON
		FROM
			[PC275-SQL\ALPHA].ClientDB.dbo.ActCalcDetail a
			INNER JOIN
				(
					SELECT
						c.value('@s', 'NVARCHAR(64)') AS SYS_REG,
						c.value('@r', 'NVARCHAR(256)') AS REASON,
						c.value('@d', 'INT') AS DISTR,
						c.value('@c', 'INT') AS COMP,
						CONVERT(SMALLDATETIME, c.value('@m', 'NVARCHAR(64)'), 112) AS MON
					FROM @XML.nodes('/root/i') AS a(c)
				) AS b ON a.SYS_REG = b.SYS_REG AND a.DISTR = b.DISTR AND a.COMP = b.COMP AND a.MON = b.MON
		*/

		UPDATE a
		SET CALC_NOTE = CASE CALC WHEN 0 THEN REASON ELSE CALC_NOTE END,
			CALC_DATE = CASE CALC WHEN 0 THEN CALC_DATE ELSE GETDATE() END
		FROM
			[PC275-SQL\ALPHA].ClientDB.dbo.ActCalcDetail a
			INNER JOIN
				(
					SELECT
						c.value('@s', 'NVARCHAR(64)') AS SYS_REG,
						c.value('@r', 'NVARCHAR(256)') AS REASON,
						c.value('@d', 'INT') AS DISTR,
						c.value('@c', 'INT') AS COMP,
						c.value('@b', 'INT') AS CALC,
						CONVERT(SMALLDATETIME, c.value('@m', 'NVARCHAR(64)'), 112) AS MON
					FROM @XML.nodes('/root/i') AS a(c)
				) AS b ON a.SYS_REG = b.SYS_REG AND a.DISTR = b.DISTR AND a.COMP = b.COMP AND a.MON = b.MON

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_CLAIM_REJECT] TO rl_act_w;
GO
