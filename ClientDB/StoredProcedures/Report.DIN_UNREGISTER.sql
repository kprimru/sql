USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[DIN_UNREGISTER]
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

		SELECT
			dbo.DistrString(SystemShortName, DF_DISTR, DF_COMP) AS [Дистрибутив],
			NT_SHORT AS [Сеть], SST_SHORT AS [Тип], dbo.DateOf(DF_CREATE) AS [Получен],
			(
				SELECT TOP 1 WEIGHT
				FROM dbo.WeightView W WITH(NOEXPAND)
				WHERE W.SystemID = b.DF_ID_SYS
					AND W.NT_ID = b.DF_ID_NET
					AND W.SST_ID = b.DF_ID_TYPE
				ORDER BY W.DATE DESC
			) AS [Вес]
		FROM
			(
				SELECT DISTINCT
					--HostID, DF_DISTR, DF_COMP,
					(
						SELECT TOP 1 DF_ID
						FROM Din.DinView z WITH(NOEXPAND)
						WHERE z.HostID = b.HostID
							AND z.DF_DISTR = a.DF_DISTR
							AND z.DF_COMP = a.DF_COMP
						ORDER BY DF_CREATE DESC
					) AS DF_ID
				FROM
					Din.DinFiles a
					INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
						WHERE z.HostID = b.HostID
							AND z.DistrNumber = DF_DISTR
							AND z.CompNumber = DF_COMP
					) AND DF_RIC = 20
			) AS a
			INNER JOIN Din.DinFiles b ON a.DF_ID = b.DF_ID
			INNER JOIN dbo.SystemTable c ON c.SystemID = b.DF_ID_SYS
			INNER JOIN Din.NetType d ON d.NT_ID = b.DF_ID_NET
			INNER JOIN Din.SystemType e ON e.SST_ID = b.DF_ID_TYPE
			INNER JOIN dbo.DistrTypeTable f ON f.DistrTypeID = NT_ID_MASTER
			INNER JOIN dbo.SystemTypeTable g ON g.SystemTypeID = SST_ID_MASTER
		WHERE /*NT_SHORT <> 'мобильная' AND */DATEDIFF(MONTH, DF_CREATE, GETDATE()) <= 6 AND SST_SHORT <> 'ДСП'
		ORDER BY /*SST_SHORT, */SystemOrder, DF_DISTR, DF_COMP
		-- без этого криво джойнит
		OPTION(FORCE ORDER)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[DIN_UNREGISTER] TO rl_report;
GO