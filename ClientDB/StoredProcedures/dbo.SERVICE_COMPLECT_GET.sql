USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_COMPLECT_GET]
	@ID_SERVICE INT
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

		SELECT DISTINCT
			R.COMPLECT,
			(
				SELECT RC.SystemBaseName + ','
				FROM Reg.RegNodeSearchView	AS RC WITH(NOEXPAND)
				WHERE (RC.COMPLECT = R.COMPLECT)
					AND (RC.DS_REG = 0)
				FOR XML PATH('')
			) as SystemsList,
			C.ClientFullName AS ClientShortName, C.ClientFullName, NT_TECH AS TechNolType
		FROM dbo.ClientView					AS C WITH(NOEXPAND)
		INNER JOIN dbo.ClientDistrView		AS CD WITH(NOEXPAND) ON C.ClientId = CD.ID_CLIENT
		INNER JOIN Reg.RegNodeSearchView	AS R WITH(NOEXPAND) ON (CD.DISTR = R.DistrNumber)
																AND (CD.COMP = R.CompNumber)
																AND (CD.SystemId = R.SystemID)
		WHERE (R.DS_REG = 0)
			AND R.COMPLECT IS NOT NULL
			AND C.ServiceID = @ID_SERVICE
		ORDER BY R.COMPLECT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SERVICE_COMPLECT_GET] TO public;
GO