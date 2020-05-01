USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_COMPLECT_PROCESS]
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

		UPDATE D
		SET UD_ID_CLIENT = C.ID_CLIENT
		FROM USR.USRData D
		CROSS APPLY
		(
			SELECT TOP (1) UF_ID
			FROM USR.USRFile F
			WHERE F.UF_ID_COMPLECT = D.UD_ID
				AND F.UF_ACTIVE = 1
			ORDER BY UF_DATE DESC, UF_CREATE DESC
		) F
		CROSS APPLY
		(
			SELECT TOP 1 ID_CLIENT
			FROM
				dbo.ClientDistrView WITH(NOEXPAND)
				INNER JOIN USR.USRPackage ON UP_ID_SYSTEM = SystemID AND UP_DISTR = DISTR AND UP_COMP = COMP
			WHERE F.UF_ID = UP_ID_USR
			ORDER BY SystemOrder, DISTR, COMP
		) C
		WHERE UD_ID_CLIENT IS NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [USR].[USR_COMPLECT_PROCESS] TO rl_usr_process;
GO