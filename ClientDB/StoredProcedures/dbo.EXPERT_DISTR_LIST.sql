USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EXPERT_DISTR_LIST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EXPERT_DISTR_LIST]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EXPERT_DISTR_LIST]
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

		DECLARE @L NVARCHAR(MAX)
		SET @L = ''

		SET @L =
			(
				SELECT
					CONVERT(VARCHAR(20), d.SystemNumber) + '_' +
					IsNull(REPLICATE('0', 6 - LEN(CONVERT(VARCHAR(20), DistrNumber))), '') + CONVERT(VARCHAR(20), DistrNumber) +
					CASE CompNumber WHEN 1 THEN '' ELSE '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(20), CompNumber))) + CONVERT(VARCHAR(20), CompNumber) END + ', '
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN
					(
						SELECT DISTINCT ID_HOST, DISTR, COMP
						FROM dbo.ExpertDistr
						WHERE STATUS = 1
					) AS b ON a.HostID = ID_HOST AND DistrNumber = DISTR AND CompNumber = COMP
					--INNER JOIN dbo.SystemTable c ON c.SystemID = a.SystemID
					INNER JOIN dbo.SystemTable d ON d.HostID = a.HostID
				--ORDER BY a.SystemOrder, DistrNumber, CompNumber
				FOR XML PATH('')
			)


		IF @L <> ''
			SET @L = LEFT(RTRIM(@L), LEN(@L) - 1)

		SELECT @L AS LIST

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EXPERT_DISTR_LIST] TO rl_expert_distr;
GO
