USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[NET_COMPL_KD]
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
			dbo.DistrString(a.SystemShortName, DistrNumber, CompNumber) AS [Дистрибутив], Comment as [Название клиента в РЦ],
			ManagerName AS [Рук-ль], RegisterDate AS [Дата регистрации], a.Complect AS [Комплект]
		FROM
			Reg.RegNodeSearchView a WITH(NOEXPAND)
			LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP AND a.HostID=b.HostId
			LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID
		WHERE
			(NT_ID=1 OR
			NT_ID BETWEEN 3 AND 6 OR
			NT_ID BETWEEN 8 AND 10) AND
			a.HostID=1 AND
			a.DS_INDEX=0 AND
			a.DistrNumber <> 20 AND
			EXISTS (
				SELECT ID
				FROM Reg.RegNodeSearchView b
				WHERE	SystemId = 85 AND
						b.DS_INDEX=0 AND
						b.Complect = a.Complect
			)
		ORDER BY a.Complect

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END

