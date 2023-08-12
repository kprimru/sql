USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_EMAIL_LOAD_FROM_PROTOCOL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_EMAIL_LOAD_FROM_PROTOCOL]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[DISTR_EMAIL_LOAD_FROM_PROTOCOL]
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

		INSERT INTO [dbo].[DistrEmail]([HostId], [Distr], [Comp], [Email], [Date], [UpdUser])
		SELECT
			[HostId]	= R.[RPR_ID_HOST],
			[Distr]		= R.[RPR_DISTR],
			[Comp]		= R.[RPR_COMP],
			[Email]		= R.[Email],
			[Date]		= Case WHEN E.[Date] > R.[RPR_DATE] THEN GetDate() ELSE R.[RPR_DATE] END,
			[UpdUser]	= R.[RPR_USER]
		FROM
		(
			SELECT
				D.[RPR_ID_HOST], D.[RPR_DISTR], D.[RPR_COMP], E.[Email], E.[RPR_DATE], E.[RPR_USER]
			FROM
			(
				SELECT DISTINCT  [RPR_ID_HOST], [RPR_DISTR], [RPR_COMP]
				FROM [dbo].[RegProtocol]
			) AS D
			CROSS APPLY
			(
				SELECT TOP 1
					[RPR_DATE],
					[RPR_OPER],
					[RPR_USER],
					[Email] = Ltrim(Rtrim(Right([RPR_OPER], Len([RPR_OPER]) - CharIndex('->', [RPR_OPER]) - 1)))
				FROM [dbo].[RegProtocol] AS E
				WHERE E.[RPR_OPER] LIKE 'Изменен email: %'
					AND E.[RPR_ID_HOST] = D.[RPR_ID_HOST]
					AND E.[RPR_DISTR] = D.[RPR_DISTR]
					AND E.[RPR_COMP] = D.[RPR_COMP]
				ORDER BY [RPR_DATE] DESC
			) AS E
			WHERE E.[Email] NOT IN ('nov1@consultant.ru', '')
		) AS R
		OUTER APPLY
		(
			SELECT TOP (1) D.*
			FROM  [dbo].[DistrEmail] AS D
			WHERE D.[HostId] = R.[RPR_ID_HOST]
				AND D.[Distr] = R.[RPR_DISTR]
				AND D.[Comp] = R.[RPR_COMP]
			ORDER BY D.[Date] DESC
		) AS E
		WHERE IsNull(E.[Email], '') != R.[Email];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
