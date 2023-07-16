USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_IMPORT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_IMPORT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_IMPORT_SELECT]
	@CLIENT		INT,
	@DISTR		INT,
	@COMMENT	VARCHAR(100),
	@SH_HIDE	BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Setting_SUBHOST_NAME	VarChar(128);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Setting_SUBHOST_NAME = Cast([System].[Setting@Get]('SUBHOST_NAME') AS VarChar(128));

		SELECT
			HostID, SystemID, DistrStr, DistrNumber, CompNumber, a.SST_SHORT,
			ISNULL(d.SST_ID_MASTER, (SELECT TOP 1 SystemTypeID FROM dbo.SystemTypeTable ORDER BY SystemTypeID)) AS SystemTypeID,
			NT_ID_MASTER AS NT_ID, a.NT_SHORT, a.DS_ID, a.DS_INDEX, CONVERT(SMALLDATETIME, RegisterDate, 104) AS RegisterDate,
			Comment, Complect,
			CONVERT(BIT,
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM
								dbo.ClientDistrView z WITH(NOEXPAND)
								INNER JOIN Reg.RegNodeSearchView y WITH(NOEXPAND) ON z.HostID = y.HostID AND z.DISTR = y.DistrNumber AND z.COMP = y.CompNumber
							WHERE z.ID_CLIENT = @CLIENT AND y.Complect = a.Complect
						) THEN 1
					ELSE 0
				END
			) AS CHECKED
		FROM
			Reg.RegNodeSearchView a WITH(NOEXPAND)
			INNER JOIN dbo.DistrStatus c ON c.DS_ID = a.DS_ID
			INNER JOIN Din.SystemType d ON d.SST_ID = a.SST_ID
			INNER JOIN Din.NetType e ON e.NT_ID = a.NT_ID
		WHERE (SubhostName = @Setting_SUBHOST_NAME OR @SH_HIDE = 0)
			AND SST_REG NOT IN ('NCT', 'HSS', 'DSP', 'NEK')
			AND c.DS_REG = 0
			AND (DistrNumber = @DISTR OR @DISTR IS NULL)
			AND (Comment LIKE @COMMENT OR @COMMENT IS NULL)
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView b WITH(NOEXPAND)
					WHERE a.HostID = b.HostID
						AND a.DistrNumber = b.DISTR
						AND a.CompNumber = b.COMP
				)
		ORDER BY Complect, SystemOrder, DistrNumber, CompNumber

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_IMPORT_SELECT] TO rl_client_distr_i;
GO
