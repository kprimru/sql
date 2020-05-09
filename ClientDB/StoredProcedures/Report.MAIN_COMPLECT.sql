USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[MAIN_COMPLECT]
	@PARAM	NVARCHAR(MAX) = NULL
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

		DECLARE @MAIN	TABLE (SYS_NAME	VARCHAR(50) PRIMARY KEY)

		INSERT INTO @MAIN(SYS_NAME)
			SELECT 'LAW'
			UNION
			SELECT 'ROS'
			UNION
			SELECT 'BUH'
			UNION
			SELECT 'BUHU'
			UNION
			SELECT 'NBU'
			UNION
			SELECT 'BUHL'
			UNION
			SELECT 'BUHUL'
			UNION
			SELECT 'JUR'
			UNION
			SELECT 'BUD'
			UNION
			SELECT 'MBP'
			UNION
			SELECT 'BUDU'


		SELECT DISTINCT
			Comment AS [Клиент],
			a.Complect AS [Номер комплекта],
			REVERSE(STUFF(REVERSE(
				(
					SELECT
						dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + '(' +
						C.NT_SHORT + ')' + ', '
					FROM Reg.RegNodeSearchView C  WITH(NOEXPAND)
					INNER JOIN @MAIN ON SYS_NAME = SystemBaseName
					WHERE c.Complect = a.Complect AND c.DS_REG = 0
					ORDER BY SystemOrder FOR XML PATH('')
				)
			), 1, 2, '')) AS [Дистрибутивы]
		FROM Reg.RegNodeSearchView A WITH(NOEXPAND)
		WHERE A.DS_REG = 0
			--AND DistrType NOT IN ('NCT', 'ADM', 'NEK')
			AND
			(
				SELECT COUNT(*)
				FROM Reg.RegNodeSearchView D WITH(NOEXPAND)
				INNER JOIN @MAIN ON d.SystemBaseName = SYS_NAME
				WHERE d.Complect = a.Complect AND d.DS_REG = 0
			) > 1
		ORDER BY Comment

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[MAIN_COMPLECT] TO rl_report;
GO