USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_SUBHOST_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_SUBHOST_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[USR_SUBHOST_SELECT]
	@SH_ID	    VARCHAR(50) = NULL,
	@SH_NAME    VarChar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@REG			VarChar(50),
		@Date			SmallDateTime;

	DECLARE @Complects Table(Id Int Primary Key Clustered);

	DECLARE @Distrs Table
	(
		[Host_Id]		SmallInt	NOT NULL,
		[Distr]			Int			NOT NULL,
		[Comp]			TinyInt		NOT NULL,
		PRIMARY KEY CLUSTERED([Host_Id], [Distr], [Comp])
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		SET @Date = DATEADD(MONTH, -1, GETDATE());

		INSERT INTO @Distrs
		SELECT HostId, DistrNumber, CompNumber
		FROM [dbo].[SubhostDistrs@Get](@SH_ID, @SH_NAME);

		INSERT INTO @Complects
		SELECT DISTINCT UD_ID
		FROM @Distrs							AS D
		INNER JOIN dbo.SystemTable				AS S ON D.Host_Id = S.HostId
		INNER JOIN USR.USRComplectNumberView	AS U WITH(NOEXPAND) ON	U.UD_SYS = S.SystemNumber
																	AND U.UD_DISTR = D.Distr
																	AND U.UD_COMP = D.Comp
		OPTION (RECOMPILE);

		SELECT
			C.Id AS UD_ID, UF_DATA, UF_NAME
		FROM @Complects C
		CROSS APPLY
		(
			SELECT TOP 1 d.UF_DATA, UF_NAME
			FROM USR.USRFile f
			INNER JOIN USR.USRFileData d ON f.UF_ID = d.UF_ID
			WHERE UF_ID_COMPLECT = C.Id
				AND UF_PATH = 2
				AND UF_CREATE >= @Date
			ORDER BY UF_CREATE DESC
		) AS F
		OPTION(RECOMPILE);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_SUBHOST_SELECT] TO rl_usr_subhost_save;
GO
