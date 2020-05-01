USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_ZVE_GET]
	@CLIENT	INT
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

		DECLARE @ZVE NVARCHAR(MAX)

		SET @ZVE = N''

		SELECT @ZVE = @ZVE + DistrStr + ', '
		FROM
			(
				SELECT DISTINCT b.DistrStr, SystemOrder, DISTR, COMP
				FROM
					dbo.RegNodeMainDistrView a WITH(NOEXPAND)
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.MainHostID = b.HostID AND a.MainDistrNumber = b.DISTR AND a.MainCompNumber = b.COMP
					INNER JOIN Din.NetType d ON d.NT_ID_MASTER = b.DistrTypeId
				WHERE b.ID_CLIENT = @CLIENT
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.ExpertDistr z
							WHERE z.ID_HOST = b.HostID AND z.DISTR = b.DISTR AND z.COMP = b.COMP
						)
					AND d.NT_TECH IN (0, 1)
			) AS o_O
		ORDER BY SystemOrder, DISTR, COMP --FOR XML PATH('')

		IF @ZVE <> ''
			SET @ZVE = 'Не подключены к ЗВЭ: ' + REVERSE(STUFF(REVERSE(@ZVE), 1, 2, ''))

		SELECT @ZVE AS ZVE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_ZVE_GET] TO public;
GO